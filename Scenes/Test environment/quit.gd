extends Button

@onready var MenuAnim: AnimationPlayer = $"../../../../MenuAnim"

func _on_pressed() -> void:
	GDSync.quit()
	MenuAnim.play("Close_Menu")
	
