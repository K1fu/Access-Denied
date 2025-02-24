extends Interactable

func _on_interacted(body):
	get_tree().change_scene_to_file("res://Scenes/2d_character_test.tscn")
