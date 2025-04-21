extends Node2D

# Preload scenes for performance
var PLAYER_SCENE : PackedScene = preload("res://Modules/Modules/2D - Player/player.tscn")
@onready var Role_Assignment : CanvasLayer = $RoleAssigning
@onready var HackerScene : PackedScene = preload("res://Modules/Modules/2D - Interact/Hacker Interact/hack_interacting_component_2d.tscn")
@onready var DeveloperScene : PackedScene = preload("res://Modules/Modules/2D - Interact/Developer Interact/dev_interacting_component_2d.tscn")
@onready var RoleText : Label = $RoleAssigning/Label

func _ready() -> void:
	# Connect GD-Sync signals
	GDSync.client_joined.connect(client_joined)
	GDSync.client_left.connect(client_left)
	GDSync.disconnected.connect(disconnected)

	# Expose local Role_Show method for remote invocation
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
	# Debug: log new player
	print("Player node created for client " + str(client_id))

func client_left(client_id : int) -> void:
	var name_str = str(client_id)
	if has_node(name_str):
		get_node(name_str).queue_free()
		print("Player node removed for client " + name_str)

func role_assign() -> void:
	# Gather and shuffle all client IDs
	var ids : Array = GDSync.get_all_clients()
	ids.shuffle()

	# Determine number of hackers based on player count
	var hacker_count : int
	if ids.size() > 4:
		hacker_count = 2
	else:
		hacker_count = 1
	print("Assigning roles for " + str(ids.size()) + " players, " + str(hacker_count) + " hackers")

	# Assign roles and notify each client
	for i in range(ids.size()):
		var client_id : int = int(ids[i])
		# Determine role
		var role : String
		if i < hacker_count:
			role = "Hacker"
		else:
			role = "Developer"
		print("Client " + str(client_id) + " assigned role " + role)

		# Ensure player node exists before adding component
		var name_str = str(client_id)
		if not has_node(name_str):
			print("Warning: player node for " + name_str + " not found, skipping component assignment")
			continue
		var player_node = get_node(name_str)

		# Add interaction component to player
		var component : Node
		if role == "Hacker":
			component = HackerScene.instantiate()
			print("Adding HackerScene to player " + name_str)
		else:
			component = DeveloperScene.instantiate()
			print("Adding DeveloperScene to player " + name_str)
		player_node.add_child(component)

		# Reveal role only to the specific client
		GDSync.call_func_on(client_id, Callable(self, "Role_Show"), [role])
		print("Sent Role_Show invocation to client " + name_str)

func Role_Show(role : String) -> void:
	# Display the role UI for this client
	RoleText.text = "You are a %s" % role
	Role_Assignment.visible = true
	print(GDSync.get_client_id(), " sees role " + role)

	# Hide after 5 seconds
	await get_tree().create_timer(5.0).timeout
	Role_Assignment.visible = false
