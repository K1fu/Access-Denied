# DeveloperPanel.gd
# Attach this to the DeveloperPanel CanvasLayer node.

extends CanvasLayer

@export var target_client_id: int = -1  # Set this before showing the panel

func _ready() -> void:
	# Connect Yes/No buttons via Callables
	$Control/Panel/VBoxContainer/ButtonsMargin/HBoxContainer/Yes.pressed.connect(Callable(self, "_on_yes_pressed"))
	$Control/Panel/VBoxContainer/ButtonsMargin/HBoxContainer/No.pressed.connect( Callable(self, "_on_no_pressed"))
	layer = 0
	visible = false  # start hidden

func show_for(client_id: int) -> void:
	target_client_id = client_id
	visible = true
	layer = 128

func _on_yes_pressed() -> void:
	# Authoritatively revoke hackability on host
	var world   = get_node("/root/World")
	var host_id = GDSync.get_host()
	GDSync.call_func_on(host_id,
		Callable(world, "revoke_hackable"),
		[target_client_id]
	)
	# Local console feedback
	var username = GDSync.get_player_data(target_client_id, "Username", "Unknown")
	print("Player %d %s is not hackable" % [target_client_id, username])

	# 1) play the Close tab tween and wait for it
	%TabAnimation.play("Close tab")
	await %TabAnimation.animation_finished


	# 2) now call click(), which itself tweens & awaits internally
	await %Update.click(100)

	# 3) only now hide
	visible = false
	layer = 0

func _on_no_pressed() -> void:
	# play Close tab animation and wait
	%TabAnimation.play("Close tab")

	visible = false
	layer = 0
