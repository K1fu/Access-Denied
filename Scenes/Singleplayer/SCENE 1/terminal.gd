extends Control

@onready var WindowAnimation: AnimationPlayer = $Container/AnimationPlayer
@onready var label: Label = $Container/MarginContainer/Label
@onready var press: Button = $Button

@export var pause_time: float = 1.0
@export var out_time: float = 0.5
@export var text_speed: float = 0.1
@export var load_scene: PackedScene  # Don't forget to assign this in the inspector

var full_text: String = "/* \n* 'A lot of hacking is playing with other people,\n* you know, getting them to do \n* strange things.'\n* -Steve Wozniak, 2004 \n\n\n* (Press anywhere to continue)"
var current_text: String = ""
var is_typing: bool = false
var text_fully_displayed: bool = false

func _ready() -> void:
	WindowAnimation.play("Open_tab")
	await WindowAnimation.animation_finished
	await get_tree().create_timer(2).timeout
	show_message()

func show_message() -> void:
	label.text = ""
	is_typing = true
	await type_text(full_text)
	is_typing = false
	text_fully_displayed = true
	await get_tree().create_timer(pause_time).timeout
	await get_tree().create_timer(out_time).timeout

func type_text(new_text: String) -> void:
	current_text = ""
	for char in new_text:
		if not is_typing:
			break
		current_text += char
		label.text = current_text
		await get_tree().create_timer(text_speed).timeout
	# If typing was interrupted, immediately show full text
	label.text = new_text

func _on_button_pressed() -> void:
	if is_typing:
		# Skip the typing animation
		is_typing = false
		label.text = full_text
	else:
		# If text is fully displayed, switch to next scene
		if text_fully_displayed:
			get_tree().change_scene_to_packed(load_scene)
