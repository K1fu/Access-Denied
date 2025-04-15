extends Interactable

@onready var sound: AudioStreamPlayer3D = $AudioStreamPlayer3D

func _on_interacted(_body):
	sound.play()
	get_tree().change_scene_to_file("res://Scenes/Log In or Sign Up/createandlogin.tscn")
