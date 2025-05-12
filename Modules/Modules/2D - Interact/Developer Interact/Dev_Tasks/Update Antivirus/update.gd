extends ProgressBar

func _ready() -> void:
	download(0)

func download(amount: int) -> void:
	# Animate the bar change over 1 second
	var tween = create_tween()
	tween.tween_property(self, "value", value + amount, 5)
	# Wait for the tween so we only sync the final result
	await tween.finished
	# Now broadcast the new value to all peers
	GDSync.sync_var(self, "value")

func click(repair: int) -> void:
	download(repair)
