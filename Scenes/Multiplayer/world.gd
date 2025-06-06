# world.gd - Full refactored without ternary operators
class_name world
extends Node2D

var role_assignments = {}

var PLAYER_SCENE: PackedScene = preload("res://Modules/Modules/2D - Player/player.tscn")
var HACKABLE_SCENE: PackedScene = preload("res://Modules/Modules/2D - Interact/Hacker Interact/Hacking/hackable.tscn")

@onready var BGM: AudioStreamPlayer2D = $BGM
@onready var UI: CanvasLayer = $TouchControl
@onready var Role_Assignment: CanvasLayer = $RoleAssigning
@onready var RoleText: Label = $RoleAssigning/Label
@onready var hacked: CanvasLayer = $Hacked
@onready var health_bar: HealthBarUI = $CanvasLayer/HealthBar
@onready var transitioncanvas: CanvasLayer = $TransitionCanvas
@onready var transition: VideoStreamPlayer = $TransitionCanvas/Transition
@onready var control_panel: Control = $ControlPanel/HackerServer/LobbyBrowsingMenu/LobbyBrowser/VBoxContainer/ControlPanel
var LABEL_SCENE: PackedScene = preload("res://Modules/Modules/2D - Interact/Hacker Interact/Hacking/CyberSecScreen/Hackables.tscn")

var Hacker_victory_scene: PackedScene = preload("res://Modules/Victiry_Module/hackers_victory.tscn")
var Developer_victory_scene: PackedScene = preload("res://Developers_victory.tscn")

# Host-side registry of roles
var host_roles: Dictionary = {}

func _ready() -> void:
	# Connect signals
	GDSync.client_joined.connect(client_joined)
	GDSync.client_left.connect(client_left)
	GDSync.disconnected.connect(disconnected)
	
	hacked.visible = false
	connect("players_received", Callable(self, "_populate_hackable_list"))

	GDSync.expose_func(Callable(self, "remote_assign_role_and_components"))
	GDSync.expose_func(Callable(self, "Role_Show"))
	GDSync.expose_func(Callable(self, "attempt_hack"))
	GDSync.expose_func(Callable(self, "revoke_hackable"))
	GDSync.expose_func(Callable(self, "send_hackables"))
	GDSync.expose_func(Callable(self, "ddos_attack"))
	GDSync.expose_func(Callable(self, "phishing"))
	GDSync.expose_func(Callable(self, "_show_hacked_transition"))
	GDSync.expose_func(Callable(self, "execute_ddos_attack"))
	GDSync.expose_func(Callable(self, "execute_phishing_attack"))
	GDSync.expose_func(Callable(self, "Hacker_victory"))
	GDSync.expose_func(Callable(self, "Developer_victory"))
	GDSync.expose_func(Callable(self, "footsteps"))

	# Spawn existing clients
	for id in GDSync.get_all_clients():
		client_joined(id)

	if GDSync.is_host():
		# Delay to ensure all clients are instantiated
		await get_tree().create_timer(0.5).timeout
		role_assign()
		# Periodic role check
		var check_timer = Timer.new()
		check_timer.wait_time = 1.0
		check_timer.one_shot = false
		check_timer.autostart = true
		add_child(check_timer)
		check_timer.timeout.connect(check_roles)
	
	BGM.play()
	
	if health_bar:
		health_bar.health_reached_max.connect(_on_health_reached_max)

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

	# Assign role if already assigned
	if role_assignments.has(client_id):
		var role = role_assignments[client_id]
		player.role = role
		GDSync.sync_var(player, "role")

func client_left(client_id: int) -> void:
	var name_str = str(client_id)
	if has_node(name_str):
		get_node(name_str).queue_free()
		print("Player node removed for client %s" % name_str)
	if host_roles.has(client_id):
		host_roles.erase(client_id)

func role_assign() -> void:
	var ids: Array = GDSync.get_all_clients()
	ids.shuffle()

	var hacker_count: int
	if ids.size() > 4:
		hacker_count = 2
	else:
		hacker_count = 1

	for i in range(ids.size()):
		var cid = ids[i]
		var player = get_node_or_null(str(cid))
		if not player:
			continue

		var role: String
		if i < hacker_count:
			role = "Hacker"
		else:
			role = "Developer"

		player.role = role
		player.is_hackable = false
		GDSync.sync_var(player, "role")
		GDSync.sync_var(player, "is_hackable")

		role_assignments[cid] = role  # Store role assignment

		GDSync.call_func_on(cid, Callable(self, "remote_assign_role_and_components"), [role])
		GDSync.call_func_on(cid, Callable(self, "Role_Show"), [role])

		if role == "Developer":
			GDSync.multiplayer_instantiate(HACKABLE_SCENE, player, true, [], true)
	transitioncanvas.visible = false
	transitioncanvas.layer = 0
	print_all_player_roles()


func remote_assign_role_and_components(role: String) -> void:
	var my_id = GDSync.get_client_id()
	var player_node = get_node_or_null(str(my_id))
	if not player_node:
		push_error("Player node for ID %d not found!" % my_id)
		return

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
	Role_Assignment.layer = 0
	transitioncanvas.visible = false
	transitioncanvas.layer = 0
	remove_child(Role_Assignment)
	print("%d sees role %s" % [GDSync.get_client_id(), role])

func print_all_player_roles() -> void:
	print("── Players & Roles ──")
	for client_id in GDSync.get_all_clients():
		var player_node = get_node_or_null(str(client_id))
		if not player_node:
			print(" • [ID %d] has no node yet." % client_id)
			continue
		var username = GDSync.get_player_data(client_id, "Username", "Unknown")
		print(" • %s — %s" % [username, player_node.role])
	print("──────────────────────")

func check_roles() -> void:
	if not GDSync.is_host():
		return

	var developers = 0
	var hackers = 0

	for client_id in GDSync.get_all_clients():
		if role_assignments.has(client_id):
			var role = role_assignments[client_id]
			if role == "Developer":
				developers += 1
			elif role == "Hacker":
				hackers += 1

	if developers == 0:
		Hacker_victory()
	if hackers == 0:
		Developer_Victory()

func _on_health_reached_max() -> void:
	if GDSync.is_host():
		Developer_Victory()

func Hacker_victory() -> void:
	if GDSync.is_host():
		print("Hackers victory")
		add_child(Hacker_victory_scene.instantiate())

func Developer_Victory() -> void:
	if GDSync.is_host():
		print("Developers victory")
		add_child(Developer_victory_scene.instantiate())

# Hacking functions (unchanged) ...
func attempt_hack(target_id: int) -> void:
	print(">>attempt_hack called!")
	var player = get_node_or_null(str(target_id))
	if player:
		player.is_hackable = true
		GDSync.sync_var(player, "is_hackable")
		print(">>" + GDSync.get_player_data(target_id, "Username", "Unknown") + " [" + player.role + "] is now hackable")
		print("──────────────────────")
		GDSync.call_func(Callable(self, "send_hackables"))

func revoke_hackable(target_id: int) -> void:
	print(">>revoke_hackable called!")
	var player = get_node_or_null(str(target_id))
	if player:
		player.is_hackable = false
		GDSync.sync_var(player, "is_hackable")
		print("Player %d %s is not hackable" % [target_id, GDSync.get_player_data(target_id, "Username", "Unknown")])
		print("──────────────────────")
		GDSync.call_func(Callable(self, "send_hackables"))

func send_hackables() -> void:
	var list: Array = []
	for id in GDSync.get_all_clients():
		var p = get_node_or_null(str(id))
		var entry = {
			"client_id": id,
			"username": GDSync.get_player_data(id, "Username", "Unknown"),
			"is_hackable": p and p.is_hackable
		}
		list.append(entry)
	_populate_hackable_list(list)

func _populate_hackable_list(players: Array) -> void:
	for child in %DevList.get_children():
		child.queue_free()
	for data in players:
		if not data.is_hackable:
			continue
		var entry = LABEL_SCENE.instantiate()
		entry.name = str(data.client_id)
		entry.get_node("UsernameBox/Username").text = data.username
		entry.get_node("HackChanceBox/HackChance").pressed.connect(Callable(self, "phishing").bind(data.client_id))
		entry.get_node("HackGuaranteeBox/HackGuarantee").pressed.connect(Callable(self, "ddos_attack").bind(data.client_id))
		%DevList.add_child(entry)

func ddos_attack(target_id: int) -> void:
	UI.layer = 0
	UI.visible = false
	GDSync.call_func(Callable(self, "execute_ddos_attack"), [target_id])
	GDSync.call_func_on(target_id, Callable(self, "_show_hacked_transition"), [])

func phishing(target_id: int) -> void:
	GDSync.call_func(Callable(self, "execute_phishing_attack"), [target_id])
	GDSync.call_func_on(target_id, Callable(self, "_show_hacked_transition"), [])

func _show_hacked_transition() -> void:
	UI.layer = 0
	UI.visible = false
	transitioncanvas.layer = 126
	transitioncanvas.visible = true
	transition.play()
	await wait_for_video_end(transition)
	transitioncanvas.layer = 0
	hacked.visible = true
	hacked.layer = 128

func wait_for_video_end(video_player: VideoStreamPlayer) -> void:
	await video_player.finished

func execute_ddos_attack(target_id: int) -> void:
	if not GDSync.is_host():
		return
	var node = get_node_or_null(str(target_id))
	if node:
		node.queue_free()
		send_hackables()

func execute_phishing_attack(target_id: int) -> void:
	if not GDSync.is_host():
		return
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var chance = rng.randi_range(1, 100)
	if chance <= 10:
		var node2 = get_node_or_null(str(target_id))
		if node2:
			node2.queue_free()
	send_hackables()

func _on_health_bar_health_reached_max() -> void:
	Developer_Victory()
