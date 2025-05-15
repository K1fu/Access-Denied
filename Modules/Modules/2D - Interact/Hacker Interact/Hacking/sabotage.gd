extends Button

@onready var HackScreen: CanvasLayer = $".."
@onready var health_bar: ProgressBar = $"../../../CanvasLayer/HealthBar"
@onready var button: Button = $"."

func _on_pressed() -> void:
	$"../../../../..".visible = false

func sabotage():
	health_bar.take_damage(10)
