extends RayCast3D

@onready var prompt = $Label

func _physics_process(_delta):
	prompt.text = ""
	
	if is_colliding():
		var collider = get_collider()
		
		prompt.text = "DETECTED... " + collider.name
