extends Node2D

# Preload scenes for performance
var PLAYER_SCENE : PackedScene = preload("res://Modules/Modules/2D - Player/player.tscn")
@onready var Role_Assignment : CanvasLayer = $RoleAssigning
@onready var RoleText : Label = $RoleAssigning/Label

# Expose remote functions in _ready()
func _ready() -> void:
	# Connect GD-Sync signals
	GDSync.client_joined.connect(client_joined)
	GDSync.client_left.connect(client_left)
	GDSync.disconnected.connect(disconnected)

	# Expose remote assignment and UI functions
	GDSync.expose_func(Callable(self, "remote_assign_role_and_components"))
	GDSync.expose_func(Callable(self, "Role_Show"))

	# Spawn players already in session
	for id in GDSync.get_all_clients():
		client_joined(id)

	# Host assigns roles when ready
	if GDSync.is_host():
		# Delay to ensure player nodes are instanced
		await get_tree().create_timer(0.1).timeout
		role_assign()

func disconnected() -> void:
	get_tree().change_scene_to_file("res://Menus/main_menu.tscn")

func client_joined(client_id : int) -> void:
	# Spawn player and set ownership
	var player = PLAYER_SCENE.instantiate()
	player.name = str(client_id)
	player.position = $StartLocation.position
	add_child(player)
	GDSync.set_gdsync_owner(player, client_id)
	print("Player node created for client " + str(client_id))

func client_left(client_id : int) -> void:
	var name_str = str(client_id)
	if has_node(name_str):
		get_node(name_str).queue_free()
		print("Player node removed for client " + name_str)

func role_assign() -> void:
	# Only host executes this
	var ids : Array = GDSync.get_all_clients()
	ids.shuffle()

	# Determine number of hackers based on player count
	var hacker_count : int
	if ids.size() > 4:
		hacker_count = 2
	else:
		hacker_count = 1
	print("Assigning roles for ", ids.size(), " players, ", hacker_count, " hackers")

	# Tell each client their role and to add components locally
	for i in range(ids.size()):
		var client_id : int = ids[i]
		var role : String
		if i < hacker_count:
			role = "Hacker"
		else:
			role = "Developer"
		print("Assigning ", role, " to client ", client_id)

		# Remote call: client adds its own components
		GDSync.call_func_on(client_id,
			Callable(self, "remote_assign_role_and_components"),
			[role]
		)
		# Remote call: client shows its role
		GDSync.call_func_on(client_id,
			Callable(self, "Role_Show"),
			[role]
		)

func remote_assign_role_and_components(role : String) -> void:
	# Called on each client to add only their role components
	var my_id = GDSync.get_client_id()
	var player_node = get_node_or_null(str(my_id))
	if not player_node:
		push_error("Player node for ID %d not found!" % my_id)
		return

	var interact_comp
	var interactable
	if role == "Hacker":
		interact_comp = preload("res://Modules/Modules/2D - Interact/Hacker Interact/hack_interacting_component_2d.tscn").instantiate()
		interactable  = preload("res://Modules/Modules/2D - Interact/Developer Interact/dev_interactable.tscn").instantiate()
	else:
		interact_comp = preload("res://Modules/Modules/2D - Interact/Developer Interact/dev_interacting_component_2d.tscn").instantiate()
		interactable  = preload("res://Modules/Modules/2D - Interact/Hacker Interact/hack_interactable2d.tscn").instantiate()

	player_node.add_child(interact_comp)
	player_node.add_child(interactable)

func Role_Show(role : String) -> void:
	# Display the role UI for this client
	RoleText.text = "You are a %s" % role
	Role_Assignment.visible = true
	print(GDSync.get_client_id(), " sees role ", role)

	# Hide after 5 seconds
	await get_tree().create_timer(5.0).timeout
	Role_Assignment.visible = false
