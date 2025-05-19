extends Button


func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://Menus/Main Menu/main_menu.tscn")
