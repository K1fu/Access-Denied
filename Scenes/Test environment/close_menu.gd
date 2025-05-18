extends Button

@onready var MenuAnim: AnimationPlayer = $"../../../../MenuAnim"

func _on_pressed() -> void:
	MenuAnim.play("Close_Menu")
