extends Button

@onready var parent: CanvasLayer = $"../../../../../.."

func _on_pressed() -> void:
	%SabotagePanelAnim.play("Close_Panel")
	parent.visible = 0
	parent.layer = 0
