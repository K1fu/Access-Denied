extends Control

@onready var WindowAnimation : AnimationPlayer = $Container/AnimationPlayer

@export var pause_time : float = 1.0         # Pause after text typing
@export var out_time : float = 0.5           # Wait time before scene change
@export var text_speed: float = 0.1          # Speed between character appearance
@onready var label: Label = $Container/MarginContainer/Label

var full_text: String = "/* \n* 'A lot of hacking is playing with other people,\n* you know, getting them to do \n* strange things.'\n* -Steve Wozniak, 2004"
var current_text: String = ""

func show_message() -> void:
	label.text = ""
	await type_text(full_text)
	await get_tree().create_timer(pause_time).timeout
	await get_tree().create_timer(out_time).timeout

func type_text(new_text: String) -> void:
	current_text = ""
	for char in new_text:
		current_text += char
		label.text = current_text
		await get_tree().create_timer(text_speed).timeout

func _ready() -> void:
	WindowAnimation.play("Open_tab")
	await WindowAnimation
	get_tree().create_timer(1.5).timeout
	show_message()
	
