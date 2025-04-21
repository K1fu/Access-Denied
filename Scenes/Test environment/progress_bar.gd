extends ProgressBar

@onready var _progress_synchronizer = $PropertySynchronizer

func _ready() -> void:
	change_health(0)  # Initialize the health bar

func change_health(amount: int):
	var tween = create_tween()
	tween.tween_property(self, "value", value + amount, 1)

func take_damage(damage: int):
	change_health(-damage)  # Subtract health

func repair_health(repair: int):
	change_health(repair)  # Add health
