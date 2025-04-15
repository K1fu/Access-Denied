extends Button

@onready var health_bar: ProgressBar = $"../../../CanvasLayer/HealthBar"

func _on_pressed() -> void:
	health_bar.repair_health(10)
