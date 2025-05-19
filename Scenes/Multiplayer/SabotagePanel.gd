extends PanelContainer

@onready var Terminal: Label = $VBoxContainer/TerminalContainer/Terminal
@onready var Sabotagee: ProgressBar = $"../../../CanvasLayer/HealthBar"

@export var pause_time: float = 0.1
@export var out_time:   float = 0.5
@export var text_speed: float = 0.1
@export var load_scene: PackedScene

var full_text: String = """
/* 
>>>Sabotaging tasks....
>>>Sabotaging...
>>>removing progress...
>>>Sabotage complete!
"""
var is_typing: bool            = false
var text_fully_displayed: bool = false

func show_message() -> void:
	Terminal.text = ""
	is_typing = true
	await type_text(full_text)
	is_typing = false
	text_fully_displayed = true
	await get_tree().create_timer(pause_time).timeout
	await get_tree().create_timer(out_time).timeout
	Terminal.text = ""

func type_text(new_text: String) -> void:
	var current_text := ""
	for char in new_text:
		current_text += char
		Terminal.text = current_text
		await get_tree().create_timer(text_speed).timeout
	Terminal.text = new_text

func Sabotage() -> void:
	type_text(full_text)
	await show_message()
	Sabotagee.take_damage(20)
	%SabotagePanelAnim.play("Close_Panel")
	get_parent().layer = 0
