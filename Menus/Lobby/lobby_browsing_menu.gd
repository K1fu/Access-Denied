extends Control

func _ready():
#	Make sure to handle disconnects!
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	GDSync.disconnected.connect(disconnected)

func disconnected():
#	Diconnected. Jump back to main menu
	get_tree().change_scene_to_file("res://Scenes/game.tscn")

func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/Test environment/game.tscn")

func _on_create_lobby_pressed():
	%LobbyCreator.visible = true

func _on_join_manual_pressed():
	%LobbyJoiner.join_manual()

func _on_lobby_browser_join_pressed(lobby_name : String, has_password : bool):
	if has_password:
		%LobbyJoiner.join_password_protected(lobby_name)
	else:
		%LobbyJoiner.join_instant(lobby_name)
