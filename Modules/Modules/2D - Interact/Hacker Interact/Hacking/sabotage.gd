extends Button

@onready var HackScreen: CanvasLayer = $".."
@onready var health_bar: ProgressBar = $"../../../CanvasLayer/HealthBar"
@onready var button: Button = $"."

func _on_pressed() -> void:
	health_bar.take_damage(10)
	HackScreen.hide()
