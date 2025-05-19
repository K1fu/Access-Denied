extends Button

@onready var parent: CanvasLayer = $"../../../../.."

func _on_pressed() -> void:
	%SabotagePanelAnim.play("Close_Panel")
	parent.visible = false
	parent.layer = 0
