extends Control

@onready var WindowAnimation: AnimationPlayer    = $Container/AnimationPlayer
@onready var label: Label                        = $Container/MarginContainer/Label
@onready var press: Button                       = $Button
@onready var beep_player: AudioStreamPlayer2D    = $AudioStreamPlayer2D

@export var pause_time: float    = 1.0
@export var out_time: float      = 0.5
@export var text_speed: float    = 0.3
@export var load_scene: PackedScene  # assign in Inspector

var full_text: String = """
/* 
* 'A lot of hacking is playing with other people,
* you know, getting them to do 
* strange things.'
* -Steve Wozniak, 2004 


* (Press anywhere to continue)
"""
var is_typing: bool = false
var text_fully_displayed: bool = false

func _ready() -> void:
	press.connect("pressed", Callable(self, "_on_button_pressed"))
	WindowAnimation.play("Open_tab")
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
	var char_count: int = 0
	var current_text := ""
	for char in new_text:
		# If skip was triggered, bail out
		if not is_typing:
			break

		# Every 2nd char, reset & play beep
		if char_count % 2 == 0:
			if beep_player.is_playing():
				beep_player.stop()
			beep_player.play(0)
		char_count += 1

		# Append and show
		current_text += char
		label.text = current_text

		# Wait unless skip comes
		await get_tree().create_timer(text_speed).timeout
	# Finalize: stop any lingering beep, show full text
	if beep_player.is_playing():
		beep_player.stop()
	label.text = new_text

func _on_button_pressed() -> void:
	if is_typing:
		# immediate skip: halt typing and beeps, show everything
		is_typing = false
		if beep_player.is_playing():
			beep_player.stop()
		label.text = full_text
	elif text_fully_displayed:
		# proceed to next scene
		get_tree().change_scene_to_packed(load_scene)
