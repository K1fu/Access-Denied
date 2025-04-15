extends CharacterBody3D

@onready var HEAD = $Head

const SENSITIVITY = 0.1
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const GRAVITY = 10.6

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * SENSITIVITY))
		HEAD.rotate_x(deg_to_rad(-event.relative.y * SENSITIVITY))

		# Clamp vertical rotation properly
		HEAD.rotation.x = clamp(HEAD.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta):
	# Apply gravityq
	if not is_on_floor():
		velocity.y = move_toward(velocity.y, -GRAVITY, delta * GRAVITY)

	# Handle jump
	if (Input.is_action_just_pressed("ui_accept")) and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Handle movement input
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction.length_squared() > 0:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = 0  # Stop instantly
		velocity.z = 0

	move_and_slide()
