extends Node2D

@onready var Hack_interactable: Area2D = $hack_interactable
@onready var HackScreen: CanvasLayer = $HackScreen
@onready var HackButton     : Button      = $HackScreen/Hack

func _ready() -> void:
	_hacker_interact()
	# — two arguments: (signal_name, Callable)
	HackButton.connect("pressed", Callable(self, "_on_hack_pressed"))

func _hacker_interact():
	Hack_interactable.interact = Hack_on_interact  # No parentheses!
	HackScreen.visible = false

func Hack_on_interact():
	print("Hacker Interacted")
	HackScreen.visible = true
