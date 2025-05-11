extends Node2D

@onready var Char_name: Label = $PanelContainer/MarginContainer/Char_Name
@onready var Dialog: Label = $PanelContainer2/Label
@onready var beep_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var Boss_Sprite: Sprite2D = $Boss
@onready var Boss_anim: AnimationPlayer = $Boss/AnimationPlayer
@onready var press: Button = $Button

@export var pause_time: float    = 0.1
@export var out_time: float      = 0.5
@export var text_speed: float    = 0.1
@export var load_scene: PackedScene

var full_text: String = """Hey pookie bear"""
var is_typing: bool = false
var text_fully_displayed: bool = false

func _ready() -> void:
	show_message()
	press.connect("pressed", Callable(self, "_on_button_pressed"))
	Boss_anim.play("Talk_Smile")

func show_message() -> void:
	Char_name.text = "Boss"
	Dialog.text = ""
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

		beep_player.play(0)

		# Append and show
		current_text += char
		Dialog.text = current_text

		# Wait unless skip comes
		await get_tree().create_timer(text_speed).timeout
	# Finalize: stop any lingering beep, show full text
	if beep_player.is_playing():
		beep_player.stop()
	Dialog.text = new_text

func _on_button_pressed() -> void:
	if is_typing:
		# immediate skip: halt typing and beeps, show everything
		is_typing = false
		if beep_player.is_playing():
			beep_player.stop()
		Dialog.text = full_text
	elif text_fully_displayed:
		# proceed to next scene
		get_tree().change_scene_to_packed(load_scene)
