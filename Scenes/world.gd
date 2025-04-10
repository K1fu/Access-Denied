extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Perform any initialization specific to the world scene here
	print("World scene is ready.")

func disconnected():
	# Handle disconnection by returning to the main menu
	get_tree().change_scene_to_file("res://Menus/main_menu.tscn")
