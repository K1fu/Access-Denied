extends Control

@onready var Glitchityglitch = $"Glitch Transition/VideoStreamPlayer"
@onready var Sound = $Theme
@onready var click = $Click

func _ready():
	Sound.play()
	Glitchityglitch.visible = false
	GDSync.connected.connect(connected)
	GDSync.connection_failed.connect(connection_failed)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_connect_pressed():
	click.play()
	%Connect.disabled = true
	GDSync.start_multiplayer()



func connected():
	%Connect.disabled = true
	await get_tree().create_timer(0.5).timeout
	
	Sound.stop()
	
	Glitchityglitch.visible = true
	Glitchityglitch.play()
	await wait_for_video_end(Glitchityglitch)
	get_tree().change_scene_to_file("res://Scenes/Test environment/game.tscn")

func wait_for_video_end(video_player: VideoStreamPlayer) -> void:
	while video_player.is_playing():
		await get_tree().process_frame

func connection_failed(error : int):
	%Connect.disabled = false
	%Message.modulate = Color.INDIAN_RED
	match(error):
		ENUMS.CONNECTION_FAILED.INVALID_PUBLIC_KEY:
			%Message.text = "The public or private key you entered were invalid."
		ENUMS.CONNECTION_FAILED.TIMEOUT:
			%Message.text = "Unable to connect, please check your internet connection."


func _on_quit_pressed() -> void:
	click.play()
	Sound.stop()
	get_tree().quit()
