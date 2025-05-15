extends Node2D

@onready var Hack_interactable: Area2D = $hack_interactable
@onready var HackScreen: CanvasLayer = $HackScreen
@onready var Hack: Control = $HackScreen/Hack

func _ready() -> void:
	HackScreen.layer = 0
	HackScreen.visible = false
	Hack_interactable.interact = Callable(self, "Hack_on_interact")

func _hacker_interact():
	Hack_interactable.interact = Callable(self, "Hack_on_interact")
	HackScreen.visible = false
	HackScreen.layer = 0

func Hack_on_interact():
	%HackAnim.play("Open_Panel")
	HackScreen.visible = true
	HackScreen.layer = 128
	Hack.visible = true
	print("── Hack attempt ──")
	print(">>Hacker interacted")

func _on_hack_pressed() -> void:
	Hack.Hack()

func _on_no_pressed() -> void:
	%HackAnim.play("Close_Panel")
	HackScreen.layer = 0
