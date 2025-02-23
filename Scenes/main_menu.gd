extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)



func _on_exit_button_button_down() -> void:
	get_tree().change_scene_to_file("res://Scenes/game.tscn")
