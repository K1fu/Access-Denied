extends Control

# Line 3: load the raw font data
@onready var font_data: FontFile = preload("res://Assets/fonts/Modenine-2OPd.ttf")

func _init():
#	Connect all signals for player joining and leaving. Also handle disconnects!
	GDSync.disconnected.connect(disconnected)
	GDSync.host_changed.connect(host_changed)
	GDSync.client_joined.connect(client_joined)
	GDSync.client_left.connect(client_left)
	GDSync.change_scene_called.connect(change_scene_called)

func disconnected():
	get_tree().change_scene_to_file("res://Menus/main_menu.tscn")

func _ready():
#	Show the start button only if this player is the host
	%Start.visible = GDSync.is_host()
	
#	Show the waiting button if not the host
	%Waiting.visible = !GDSync.is_host()

func host_changed(is_host : bool, _new_host_id : int):
#	Update the buttons if the host changes
#	This may happen if the current host leaves
	%Start.visible = is_host
	%Waiting.visible = !is_host

func client_joined(client_id : int):
#	 # If a player joins display their username and color
	var label : Label = Label.new()
	label.name = str(client_id)
	
	# Line 33: apply the DynamicFont with the proper override key
	label.add_theme_font_override("font", font_data)
	%PlayerList.add_child(label)
	
	# Get their username using their Client ID. Fallback if missing
	label.text = GDSync.get_player_data(client_id, "Username", "Unknown")
	# Get their color, fallback white
	label.modulate = GDSync.get_player_data(client_id, "Color", Color.WHITE)
	# Update the current player count display
	%PlayerCount.text = str(GDSync.get_lobby_player_count())+"/"+str(GDSync.get_lobby_player_limit())

func client_left(client_id : int):
#	Remove the client that left from the list
	if %PlayerList.has_node(str(client_id)):
		%PlayerList.get_node(str(client_id)).queue_free()
	
#	Update the current player count display
	%PlayerCount.text = str(GDSync.get_lobby_player_count())+"/"+str(GDSync.get_lobby_player_limit())

func change_scene_called(scene_path : String):
	%Start.visible = false
	%Waiting.visible = false
	%Leave.visible = false
	%Loading.visible = true

func _on_start_pressed():
#	Close the lobby so that no new players can join
	GDSync.close_lobby()
	
#	Switch scenes using GD-Sync
	GDSync.change_scene("res://Scenes/Multiplayer/world.tscn")

func _on_leave_pressed():
#	Leave the current lobby and switch back to the lobby browser
	GDSync.leave_lobby()
	get_tree().change_scene_to_file("res://Menus/Lobby/lobby_browsing_menu.tscn")
