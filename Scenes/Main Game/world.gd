extends Node2D

var PLAYER_SCENE : PackedScene = load("res://Modules/Modules/2D - Player/player.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GDSync.client_joined.connect(client_joined)
	GDSync.client_left.connect(client_left)
	GDSync.disconnected.connect(disconnected)

	for id in GDSync.get_all_clients():
		client_joined(id)

func disconnected():
	get_tree().change_scene_to_file("res://Menus/main_menu.tscn")

func client_joined(client_id : int):
#	Instantiate a player
	var player : Node = PLAYER_SCENE.instantiate()
	
#	Make the ID their name for easy identification
	player.name = str(client_id)
	player.position = $StartLocation.position
	add_child(player)
	
#	Make sure to make the client the owner of their own player controller
	GDSync.set_gdsync_owner(player, client_id)

func client_left(client_id : int):
#	When a client leaves, delete their player controller
	var player_string : String = str(client_id)
	if has_node(player_string):
		get_node(player_string).queue_free()
