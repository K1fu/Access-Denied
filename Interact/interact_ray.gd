extends RayCast3D

func _physics_process(_delta):
	if is_colliding():
		print("Collidee")
