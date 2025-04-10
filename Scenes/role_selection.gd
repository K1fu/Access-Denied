extends Node2D

@export var RoleAnnounce = "You are a"

@export var fade_in_time : float = 1.0  # Duration for fading in
@export var fade_out_time : float = 1.0  # Duration for fading out
@export var display_time : float = 4.0  # Time to display the role before fading out

@onready var label = $CanvasLayer/FadeRect/Label  # Reference to the label node
@onready var fade_rect = $CanvasLayer/FadeRect  # Reference to the fade-in/out rectangle

# Role dictionary synchronized via GDSync
var player_roles : Dictionary = {}
var hacker_count : int = 0  # Tracks the number of hackers assigned

func _ready() -> void:
	# Start the fade-in transition
	await fade_in()

	# Display the player's role
	var client_id = GDSync.get_client_id()  # Corrected function call
	if player_roles.has(client_id):
		var role = player_roles[client_id]
		label.text = "%s %s" % [RoleAnnounce, role]
	else:
		label.text = "%s Developer" % RoleAnnounce  # Default role if not assigned

	# Wait for the display time, then fade out and change the scene
	await get_tree().create_timer(display_time).timeout
	await fade_out()

	# Transition to the game scene
	GDSync.change_scene("res://Scenes/Multiplayer game/world.tscn")

func fade_in() -> void:
	# Start with the fade_rect fully opaque
	fade_rect.self_modulate = Color(0, 0, 0, 1.0)
	fade_rect.show()

	# Fade to transparent
	var tween = get_tree().create_tween()
	tween.tween_property(fade_rect, "self_modulate:a", 0.0, fade_in_time)
	await tween.finished

func fade_out() -> void:
	# Start with the fade_rect fully transparent
	fade_rect.self_modulate = Color(0, 0, 0, 0.0)
	fade_rect.show()

	# Fade to opaque
	var tween = get_tree().create_tween()
	tween.tween_property(fade_rect, "self_modulate:a", 1.0, fade_out_time)
	await tween.finished

func disconnected():
	# Handle disconnection by returning to the main menu
	get_tree().change_scene_to_file("res://Menus/main_menu.tscn")

func client_joined(client_id : int):
	# Assign a role to the player when they join
	var total_players = GDSync.get_all_clients().size()
	var role : String = "Developer"

	if hacker_count < 1 or (hacker_count < 2 and total_players >= 7):
		if randi() % 2 == 0:
			role = "Hacker"
			hacker_count += 1

	player_roles[client_id] = role
	print("Player %s assigned role: %s" % [client_id, role])

func client_left(client_id : int):
	# Remove the player's role when they leave
	if player_roles.has(client_id):
		if player_roles[client_id] == "Hacker":
			hacker_count -= 1
		player_roles.erase(client_id)
