extends Control

@onready var Glitchityglitch = $"Glitch Transition"

func _ready():
#	Connect all signals related to connecting to the servers
	Glitchityglitch.visible = false
	GDSync.connected.connect(connected)
	GDSync.connection_failed.connect(connection_failed)
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_connect_pressed():
	%Connect.disabled = true
	
#	Start the multiplayer plugin
	GDSync.start_multiplayer()

func _on_quit_pressed():
	get_tree().quit()

func connected():
	%Connect.disabled = true

	await get_tree().create_timer(0.5).timeout
	
	Glitchityglitch.visible = true
	
	var video_player = Glitchityglitch.get_node("VideoStreamPlayer")
	video_player.play()

	# Wait until the video finishes playing
	await wait_for_video_end(video_player)

	get_tree().change_scene_to_file("res://Scenes/Test environment/game.tscn")

func wait_for_video_end(video_player: VideoStreamPlayer) -> void:
	while video_player.playing:
		await get_tree().process_frame

func connection_failed(error : int):
#	Connection failed. Display the possible error messages
	%Connect.disabled = false
	%Message.modulate = Color.INDIAN_RED
	match(error):
		ENUMS.CONNECTION_FAILED.INVALID_PUBLIC_KEY:
			%Message.text = "The public or private key you entered were invalid."
		ENUMS.CONNECTION_FAILED.TIMEOUT:
			%Message.text = "Unable to connect, please check your internet connection."
