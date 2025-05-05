class_name Hack_Button
extends Button

@onready var world = get_tree().get_root().get_node("World")

# ← Define this so _on_pressed() can find the Player node
func find_target_node() -> CharacterBody2D:
	# Button → HackScreen → Hackable → Player
	var hackable_node = get_parent().get_parent()
	var player_node   = hackable_node.get_parent()
	return player_node

func _on_pressed() -> void:
	var target = find_target_node()
	if target:
		# Sends the hack request to the host (via GD-Sync)
		GDSync.call_func(Callable(world, "attempt_hack"), [target.client_id])
	else:
		print("No valid hack target in range.")
	visible = false
