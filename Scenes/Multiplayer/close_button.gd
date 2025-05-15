extends Button

@onready var parent = $"../../../../.."

func _on_pressed() -> void:
	%DeveloperTaskAnim.play("Close_Task")
	
	parent.layer = 0
	parent.visible = false
