extends StaticBody2D

#This is the interactable object.

@onready var Dev_interactable: Area2D = $dev_interactable
@onready var Hack_interactable: Area2D = $hack_interactable
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var CrewScreen: Button = $CanvasLayer/Button1
	
func _ready() -> void:
	_crewmate_interact()
	_hacker_interact()

func _crewmate_interact():
	Dev_interactable.interact = Dev_on_interact  # Assign function to interaction
	Dev_interactable.connect("area_entered", Dev_on_area_entered)
	Dev_interactable.connect("area_exited", Dev_on_area_exited)
	CrewScreen.visible = false

func Dev_on_interact():
	print("Interacted")
	CrewScreen.visible = true

func Dev_on_area_entered(area: Area2D):
	if area.is_in_group("damage_areas") :
		print("Entered:", area.name)

func Dev_on_area_exited(area: Area2D):
	if area.is_in_group("damage_areas") :
		print("Exited:", area.name)
		CrewScreen.visible = false

func _hacker_interact():
	Hack_interactable.interact = Hack_on_interact  # Assign function to interaction
	Hack_interactable.connect("area_entered", Hack_on_area_entered)
	Hack_interactable.connect("area_exited", Hack_on_area_exited)
	CrewScreen.visible = false

func Hack_on_interact():
	print("Interacted")
	CrewScreen.visible = true

func Hack_on_area_entered(area: Area2D):
	if area.is_in_group("damage_areas") :
		print("Entered:", area.name)

func Hack_on_area_exited(area: Area2D):
	if area.is_in_group("damage_areas") :
		print("Exited:", area.name)
		CrewScreen.visible = false
