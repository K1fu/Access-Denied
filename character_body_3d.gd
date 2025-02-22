extends CharacterBody3D

@onready var HEAD = $Head
@onready var JUMP_BTN = $JumpBtn

const SENSITIVITY = 0.25
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const GRAVITY = 10.6  # Gravity should be positive

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(event.relative.x * SENSITIVITY ))
		HEAD.rotate_x(deg_to_rad(-event.relative.y * SENSITIVITY))
		
		HEAD.rotation.x = clamp(HEAD.rotation.x, deg_to_rad(-45), deg_to_rad(60))
		

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y -= GRAVITY * delta  # Use defined GRAVITY instead of get_gravity()

	# Handle jump
	if Input.is_action_just_pressed("ui_accept") or JUMP_BTN.is_pressed() and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle movement
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction.length_squared() > 0:  # Slight optimization
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	# Move the character
	move_and_slide()
