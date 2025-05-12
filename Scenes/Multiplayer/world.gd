class_name world
extends Node2D

var PLAYER_SCENE: PackedScene = preload("res://Modules/Modules/2D - Player/player.tscn")
var HACKABLE_SCENE: PackedScene = preload("res://Modules/Modules/2D - Interact/Hacker Interact/Hacking/hackable.tscn")

@onready var Role_Assignment: CanvasLayer = $RoleAssigning
@onready var RoleText: Label = $RoleAssigning/Label
@onready var hacked: CanvasLayer = $Hacked

#---------------------CyberSecScreen vars---------------------#
@onready var control_panel: Control = $ControlPanel/ControlPanel2/LobbyBrowsingMenu/LobbyBrowser/VBoxContainer/ControlPanel

var LABEL_SCENE: PackedScene = preload(
	"res://Modules/Modules/2D - Interact/Hacker Interact/Hacking/CyberSecScreen/Hackables.tscn"
)
#-------------------------------------------------------------#

@onready var transition: VideoStreamPlayer = $TransitionCanvas/Transition
@onready var transitioncanvas: CanvasLayer = $TransitionCanvas

func _ready() -> void:
	
	%developers_victory.visible = false
	%HackersVictory.visible = false
	
	GDSync.client_joined.connect(client_joined)
	GDSync.client_left.connect(client_left)
	GDSync.disconnected.connect(disconnected)
	
	hacked.visible = false
	
	
	
	connect("players_received", Callable(self, "_populate_hackable_list"))
	send_hackables()

	GDSync.expose_func(Callable(self, "remote_assign_role_and_components"))
	GDSync.expose_func(Callable(self, "Role_Show"))
	GDSync.expose_func(Callable(self, "attempt_hack"))
	GDSync.expose_func(Callable(self, "revoke_hackable"))                # expose new function
	GDSync.expose_func(Callable(self, "send_hackables"))
	GDSync.expose_func(Callable(self, "ddos_attack"))
	GDSync.expose_func(Callable(self, "phishing"))
	GDSync.expose_func(Callable(self, "_show_hacked_transition"))
	GDSync.expose_func(Callable(self, "execute_ddos_attack"))
	GDSync.expose_func(Callable(self, "execute_phishing_attack"))

	for id in GDSync.get_all_clients():
		client_joined(id)
	
	if GDSync.is_host():
		await get_tree().create_timer(0.1).timeout
		role_assign()
		
	var t = Timer.new()
	t.wait_time = 2    
	t.one_shot = false
	t.autostart = true
	add_child(t)
	t.timeout.connect(Callable(self, "send_hackables"))
	
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

		GDSync.call_func_on(cid, Callable(self, "remote_assign_role_and_components"), [role])
		GDSync.call_func_on(cid, Callable(self, "Role_Show"), [role])

		if role == "Developer":
			GDSync.multiplayer_instantiate(HACKABLE_SCENE, player, true, [], true)
	transitioncanvas.visible = false
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
	print("%d sees role %s" % [GDSync.get_client_id(), role])

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

#---------------------Hacking functions---------------------#

func attempt_hack(target_id: int) -> void:
	print(">>attempt_hack called!")
	var player = get_node_or_null(str(target_id))
	if player:
		player.is_hackable = true
		GDSync.sync_var(player, "is_hackable")
		var username = GDSync.get_player_data(target_id, "Username", "Unknown")
		print(">>%s [%s] is now hackable" % [username, player.role])
		print("──────────────────────")

# Reverse function to clear hackable status
func revoke_hackable(target_id: int) -> void:
	print(">>revoke_hackable called!")
	var player = get_node_or_null(str(target_id))
	if player:
		player.is_hackable = false
		GDSync.sync_var(player, "is_hackable")
		var username = GDSync.get_player_data(target_id, "Username", "Unknown")
		print("Player %d %s is not hackable" % [target_id, username])
		print("──────────────────────")

func send_hackables() -> void:
	var list: Array = []
	for id in GDSync.get_all_clients():
		var player_node = get_node_or_null(str(id))
		var username = GDSync.get_player_data(id, "Username", "Unknown")
		var is_hackable = player_node and player_node.is_hackable
		list.append({
			"client_id": id,
			"username": username,
			"is_hackable": is_hackable
		})
	_populate_hackable_list(list)

func _populate_hackable_list(players: Array) -> void:
	for child in %DevList.get_children():
		child.queue_free()

	for data in players:
		if not data.is_hackable:
			continue

		var entry = LABEL_SCENE.instantiate()
		entry.name = str(data.client_id)

		var name_lbl = entry.get_node("UsernameBox/Username") as Label
		if name_lbl:
			name_lbl.text = data.username
		else:
			push_error("UsernameBox/Label not found!")

		var chance_btn = entry.get_node("HackChanceBox/HackChance") as Button
		if chance_btn:
			chance_btn.pressed.connect(Callable(self, "phishing").bind(data.client_id))

		var guar_btn = entry.get_node("HackGuaranteeBox/HackGuarantee") as Button
		if guar_btn:
			guar_btn.pressed.connect(Callable(self, "ddos_attack").bind(data.client_id))

		%DevList.add_child(entry)

func ddos_attack(target_id: int) -> void:
	GDSync.call_func(Callable(self, "execute_ddos_attack"), [target_id])
	GDSync.call_func_on(target_id, Callable(self, "_show_hacked_transition"), [])

func phishing(target_id: int) -> void:
	GDSync.call_func(Callable(self, "execute_phishing_attack"), [target_id])
	GDSync.call_func_on(target_id, Callable(self, "_show_hacked_transition"), [])

func _show_hacked_transition() -> void:
	transitioncanvas.visible = true
	transition.play()
	await wait_for_video_end(transition)
	hacked.visible = true

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
	if rng.randi_range(1, 100) <= 20:
		var node = get_node_or_null(str(target_id))
		if node:
			node.queue_free()
	send_hackables()
