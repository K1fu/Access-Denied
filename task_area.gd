extends StaticBody2D

# This is the interactable object.

@onready var Dev_interactable: Area2D = $dev_interactable
@onready var Hack_interactable: Area2D = $hack_interactable
@onready var CrewScreen: CanvasLayer = $Developer
@onready var HackScreen: CanvasLayer = $Hacker

func _ready() -> void:
	_crewmate_interact()
	_hacker_interact()

func _crewmate_interact():
	Dev_interactable.interact = Dev_on_interact  # No parentheses!

func Dev_on_interact():
	print("Developer Interacted")
	%DeveloperTaskAnim.play("Open_Task")
	CrewScreen.layer = 128
	CrewScreen.visible = true

func _hacker_interact():
	Hack_interactable.interact = Hack_on_interact  # No parentheses!

func Hack_on_interact():
	print("Hacker Interacted")
	%SabotagePanelAnim.play("Open_Panel")
	HackScreen.layer = 128
	HackScreen.visible = true
