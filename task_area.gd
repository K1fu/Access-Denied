extends StaticBody2D

@onready var interactable: Area2D = $Interactable
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var Task: CanvasLayer = $CanvasLayer
	
func _ready() -> void:
	interactable.interact = _on_interact
	Task.visible = false
	
	
func _on_interact():
	Task.visible = true
