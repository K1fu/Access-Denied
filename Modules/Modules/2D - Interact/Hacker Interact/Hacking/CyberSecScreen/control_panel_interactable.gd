# ControlPanel.gd  (attached to your /ControlPanel StaticBody2D node)
extends StaticBody2D

@onready var Dev_interactable: Area2D       = $dev_interactable
@onready var Hack_interactable: Area2D      = $hack_interactable
@onready var ControlPanel: CanvasLayer      = $HackerServer
@onready var DeveloperPanel: CanvasLayer    = $DeveloperPanel
@onready var Antivirus: Control         = $DeveloperPanel/Control  # or wherever your panel’s content lives

func _ready() -> void:
	_crewmate_interact()
	_hacker_interact()

func _crewmate_interact():
	Dev_interactable.interact = Dev_on_interact
	Antivirus.visible = false

func Dev_on_interact():
	print("Developer Interacted")
	%TabAnimation.play("Open tab")
	Antivirus.visible = true

	# ——— NEW: invoke your popup logic here ———
	# If DeveloperPanel.gd has `func show_for(client_id)`, call:
	# Assume this script lives under the Player node, so you know your client_id:
	var my_id = GDSync.get_client_id()
	DeveloperPanel.show_for(my_id)
	# Now the Yes/No panel is hooked up and knows which client to revoke.

func _hacker_interact():
	Hack_interactable.interact = Hack_on_interact
	ControlPanel.visible = false

func Hack_on_interact():
	print("Hacker Interacted")
	ControlPanel.visible = true

func _on_button_pressed() -> void:
	ControlPanel.visible = false
