extends Control

@onready var login_button = $Label/Button
@onready var create_account_button = $Label2/Button

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	login_button.pressed.connect(on_login_pressed)
	create_account_button.pressed.connect(on_create_account_pressed)

func on_login_pressed():
	get_tree().change_scene_to_file("res://GD-SyncTemplates/Accounts/login.tscn")

func on_create_account_pressed():
	get_tree().change_scene_to_file("res://GD-SyncTemplates/Accounts/create_account.tscn")
