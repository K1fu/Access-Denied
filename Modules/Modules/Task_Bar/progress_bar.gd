# HealthBar.gd
# Attach this to your ProgressBar node.

extends ProgressBar

class_name HealthBarUI

signal health_reached_max 

static var instance: HealthBarUI

func _ready() -> void:
	instance = self
	# Expose the `value` property on *this* node so GD-Sync can replicate it
	GDSync.expose_var(self, "value")      # ← two arguments required by the API :contentReference[oaicite:0]{index=0}
	change_health(0)  # Initialize bar at startup

func change_health(amount: int) -> void:
	var target_value = clamp(value + amount, 0, max_value)  # Clamp values
	var tween = create_tween()
	tween.tween_property(self, "value", target_value, 1)
	await tween.finished
	GDSync.sync_var(self, "value")
	
	if target_value >= max_value:
		health_reached_max.emit()

func take_damage(damage: int) -> void:
	change_health(-damage)

func repair_health(repair: int) -> void:
	change_health(repair)
