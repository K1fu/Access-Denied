extends Node

@onready var Hack_interactable: Area2D = $hack_interactable
@onready var HackScreen: CanvasLayer = $HackScreen

func _ready() -> void:
	_hacker_interact()

func _hacker_interact():
	Hack_interactable.interact = Hack_on_interact  # No parentheses!
	HackScreen.visible = false

func Hack_on_interact():
	print("Hacker Interacted")
	HackScreen.visible = true
