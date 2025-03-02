extends Interactable

func _on_interacted(_body):
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
