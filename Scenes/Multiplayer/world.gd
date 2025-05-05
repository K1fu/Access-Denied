class_name world
extends Node2D

# Preload scenes for performance
var PLAYER_SCENE: PackedScene = preload("res://Modules/Modules/2D - Player/player.tscn")
var HACKABLE_SCENE: PackedScene = preload("res://Modules/Modules/2D - Interact/Hacker Interact/Hacking/hackable.tscn")

@onready var Role_Assignment: CanvasLayer = $RoleAssigning
@onready var RoleText: Label = $RoleAssigning/Label

func _ready() -> void:
	# Connect GD-Sync signals
	GDSync.client_joined.connect(client_joined)
	GDSync.client_left.connect(client_left)
	GDSync.disconnected.connect(disconnected)

	# Expose remote functions
	GDSync.expose_func(Callable(self, "remote_assign_role_and_components"))
	GDSync.expose_func(Callable(self, "Role_Show"))
	GDSync.expose_func(Callable(self, "attempt_hack"))

	# Spawn existing clients
	for id in GDSync.get_all_clients():
		client_joined(id)

	# Host decides roles when ready
	if GDSync.is_host():
		await get_tree().create_timer(0.1).timeout
		role_assign()

func disconnected() -> void:
	get_tree().change_scene_to_file("res://Menus/main_menu.tscn")

func client_joined(client_id: int) -> void:
	var player = PLAYER_SCENE.instantiate()
	player.name = str(client_id)
	player.position = $StartLocation.position
	add_child(player)
	GDSync.set_gdsync_owner(player, client_id)

	player.client_id = client_id
	GDSync.sync_var(player, "client_id")

	var username = GDSync.get_player_data(client_id, "Username", "Unknown")
	print("Spawned %s with client_id = %d" % [username, client_id])

func client_left(client_id: int) -> void:
	var name_str = str(client_id)
	if has_node(name_str):
		get_node(name_str).queue_free()
		print("Player node removed for client " + name_str)

func role_assign() -> void:
	var ids: Array = GDSync.get_all_clients()
	ids.shuffle()

	# Determine number of hackers
	var hacker_count: int
	if ids.size() > 4:
		hacker_count = 2
	else:
		hacker_count = 1

	print("Assigning roles for %d players, %d hackers" % [ids.size(), hacker_count])

	for i in range(ids.size()):
		var client_id = ids[i]
		var player = get_node_or_null(str(client_id))
		if not player:
			continue

		# Assign role based on index
		var role: String
		if i < hacker_count:
			role = "Hacker"
		else:
			role = "Developer"

		# Sync role and hackable status
		player.role = role
		player.is_hackable = false
		GDSync.sync_var(player, "role")
		GDSync.sync_var(player, "is_hackable")

		# Instruct each client to add their interact component
		GDSync.call_func_on(client_id, Callable(self, "remote_assign_role_and_components"), [role])
		GDSync.call_func_on(client_id, Callable(self, "Role_Show"), [role])

		# Host-spawn & sync hackable for developers
		if GDSync.is_host() and role == "Developer":
			GDSync.multiplayer_instantiate(HACKABLE_SCENE, player, true, [], true)

	print_all_player_roles()

func remote_assign_role_and_components(role: String) -> void:
	var my_id = GDSync.get_client_id()
	var player_node = get_node_or_null(str(my_id))
	if not player_node:
		push_error("Player node for ID %d not found!" % my_id)
		return

	# Instantiate the correct interact component
	var interact_comp: Node2D
	if role == "Hacker":
		interact_comp = preload("res://Modules/Modules/2D - Interact/Hacker Interact/hack_interacting_component_2d.tscn").instantiate()
	else:
		interact_comp = preload("res://Modules/Modules/2D - Interact/Developer Interact/dev_interacting_component_2d.tscn").instantiate()

	player_node.add_child(interact_comp)
	var username = GDSync.get_player_data(my_id, "Username", "Unknown")
	print("%s: interact_comp assigned to %s (%d)" % [role, username, my_id])

func Role_Show(role: String) -> void:
	RoleText.text = "You are a %s" % role
	Role_Assignment.visible = true
	await get_tree().create_timer(5.0).timeout
	Role_Assignment.visible = false
	print("%d sees role %s" % [GDSync.get_client_id(), role])

func attempt_hack(target_id: int) -> void:
	if not GDSync.is_host():
		return
	var player = get_node_or_null(str(target_id))
	if player:
		player.is_hackable = true
		GDSync.sync_var(player, "is_hackable")
		var username = GDSync.get_player_data(target_id, "Username", "Unknown")
		print("%s [%s] is now hackable" % [username, player.role])

func print_all_player_roles() -> void:
	print("── Players & Roles ──")
	for client_id in GDSync.get_all_clients():
		var player_node = get_node_or_null(str(client_id))
		if not player_node:
			print(" • [ID %d] has no node yet." % client_id)
			continue
		var username = GDSync.get_player_data(client_id, "Username", "Unknown")
		var role = player_node.role
		print(" • %s — %s" % [username, role])
	print("──────────────────────")
