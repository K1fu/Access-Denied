extends CanvasLayer


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Menus/Lobby/lobby_browsing_menu.tscn")


func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://Menus/Main Menu/main_menu.tscn")
