class_name Hack_Button
extends Button

# Avoid shadowing the global World class
@onready var world_node = get_tree().get_root().get_node("World")

func find_target_node() -> CharacterBody2D:
	var hackable_node = get_parent().get_parent()
	return hackable_node.get_parent()

func Hack() -> void:
	print(">>Hacker Requested Hack")
	var target = find_target_node()
	if target:
		print(">>target found")
		GDSync.call_func(Callable(world_node, "attempt_hack"), [target.client_id])
	else:
		print(">>No valid hack target in range.")
	$".".visible = false
	$"..".layer = 0
