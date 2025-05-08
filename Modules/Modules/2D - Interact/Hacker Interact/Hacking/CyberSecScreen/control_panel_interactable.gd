extends StaticBody2D

@onready var Dev_interactable: Area2D = $dev_interactable
@onready var Hack_interactable: Area2D = $hack_interactable
@onready var ControlPanel: CanvasLayer = $ControlPanel2
@onready var botton: Button = $ControlPanel2/LobbyBrowsingMenu/LobbyBrowser/VBoxContainer/Button

func _ready() -> void:
	_crewmate_interact()
	_hacker_interact()

func _crewmate_interact():
	Dev_interactable.interact = Dev_on_interact  # No parentheses!
	ControlPanel.visible = false

func Dev_on_interact():
	print("Developer Interacted")
	ControlPanel.visible = true

func _hacker_interact():
	Hack_interactable.interact = Hack_on_interact  # No parentheses!
	ControlPanel.visible = false

func Hack_on_interact():
	print("Hacker Interacted")
	ControlPanel.visible = true

func _on_button_pressed() -> void:
	ControlPanel.visible = false
