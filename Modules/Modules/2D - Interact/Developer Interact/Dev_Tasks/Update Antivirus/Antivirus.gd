class_name Antivirus

extends Control

@onready var world_node   = get_tree().get_root().get_node("World")
@onready var Terminal     = $Panel/VBoxContainer/Hacking/Terminal as Label

@export var pause_time: float = 0.1
@export var out_time:   float = 0.5
@export var text_speed: float = 0.1
@export var load_scene: PackedScene

var full_text: String = """
/* 
>>>Hacking player
>>>Hackening...
>>>Hookening...
>>>Hacking complete!
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

func find_target_node() -> CharacterBody2D:
	var hackable_node = get_parent().get_parent()
	return hackable_node.get_parent()

func Hack() -> void:
	print(">>Hacker Requested Hack")
	await show_message()
	var target = find_target_node()
	if target:
		print(">>target found")
		GDSync.call_func(Callable(world_node, "attempt_hack"), [target.client_id])
		self.visible = false
		$"..".layer = 0
	else:
		print(">>No valid hack target in range.")
