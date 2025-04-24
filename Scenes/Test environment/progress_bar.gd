# HealthBar.gd
# Attach this to your ProgressBar node.

extends ProgressBar

func _ready() -> void:
	# Expose the `value` property on *this* node so GD-Sync can replicate it
	GDSync.expose_var(self, "value")      # ← two arguments required by the API :contentReference[oaicite:0]{index=0}
	change_health(0)  # Initialize bar at startup

func change_health(amount: int) -> void:
	# Animate the bar change over 1 second
	var tween = create_tween()
	tween.tween_property(self, "value", value + amount, 1)
	# Wait for the tween so we only sync the final result
	await tween.finished
	# Now broadcast the new value to all peers
	GDSync.sync_var(self, "value")

func take_damage(damage: int) -> void:
	change_health(-damage)

func repair_health(repair: int) -> void:
	change_health(repair)
