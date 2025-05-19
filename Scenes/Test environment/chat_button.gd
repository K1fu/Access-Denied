extends Button

@onready var Chat = $"../TextChat"

func _on_toggled(toggled_on: bool) -> void:
	Chat.visible = toggled_on
