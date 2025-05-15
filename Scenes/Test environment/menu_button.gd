extends Button

@onready var MenuAnim: AnimationPlayer = $"../Menu/MenuAnim"

func _on_pressed() -> void:
	MenuAnim.play("Open_Menu")
