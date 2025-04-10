extends StaticBody2D

#This is the interactable object.

@onready var interactable: Area2D = $Interactable
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var CrewScreen: Button = $CanvasLayer/Button1
	
func _ready() -> void:
	_crewmate_interact()

func _crewmate_interact():
	interactable.interact = _on_interact  # Assign function to interaction
	interactable.connect("area_entered", _on_area_entered)
	interactable.connect("area_exited", _on_area_exited)
	CrewScreen.visible = false

func _on_interact():
	print("Interacted")
	CrewScreen.visible = true

func _on_area_entered(area: Area2D):
	print("Entered:", area.name)

func _on_area_exited(area: Area2D):
	print("Exited:", area.name)
	CrewScreen.visible = false
