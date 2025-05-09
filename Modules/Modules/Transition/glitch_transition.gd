extends Node2D

@onready var Video = $VideoStreamPlayer
func _ready() -> void:
	Video.play()
	Video.loop
