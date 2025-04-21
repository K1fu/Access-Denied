extends Button

@onready var health_bar: ProgressBar = $"../../../CanvasLayer/HealthBar"
@onready var button: Button = $"."

func _on_pressed() -> void:
	health_bar.repair_health(10)
	button.visible = false
