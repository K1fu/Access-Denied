class_name Player
extends CharacterBody2D

@export var speed: int = 300
@export var sprint_multiplier: float = 1.5
@export var normal_anim_speed: float = 1.0
@export var sprint_anim_speed: float = 1.5
@export var client_id: int = 0
@export var is_hackable: bool = false
@export var role: String = ""

@onready var _username: Label = $Username
@onready var _position_synchronizer = $PropertySynchronizer
@onready var char_skin = $Character/CharacterSkin
@onready var FootstepsPlayer: AudioStreamPlayer2D = $Footsteps

var last_direction: String = "down"

func _ready():
	GDSync.expose_node(self)
	GDSync.sync_var(self, "is_hackable")
	char_skin = $Character/CharacterSkin
	GDSync.sync_var(self, "client_id")
	set_multiplayer_data.call_deferred()
	GDSync.sync_var(self, "role")
	FootstepsPlayer.stop()

func set_multiplayer_data():
	var client_id_int = name.to_int()
	_username.text = GDSync.get_player_data(client_id_int, "Username", "Unknown")
	_username.visible = not GDSync.is_gdsync_owner(self)

func get_input():
	# Input and speed calculation
	var input_direction = Vector2.ZERO
	input_direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	var current_speed = speed
	var sprinting = false
	if Input.is_action_pressed("Sprint"):
		current_speed = speed * sprint_multiplier
		sprinting = true
		
	velocity = input_direction.normalized() * current_speed

	# Track last movement direction
	if input_direction != Vector2.ZERO:
		if input_direction.x > 0:
			last_direction = "right"
		elif input_direction.x < 0:
			last_direction = "left"
		elif input_direction.y > 0:
			last_direction = "down"
		elif input_direction.y < 0:
			last_direction = "up"

	# Determine direction vector for animation
	var direction_vector = input_direction
	if direction_vector == Vector2.ZERO:
		if last_direction == "up":
			direction_vector = Vector2(0, -1)
		elif last_direction == "down":
			direction_vector = Vector2(0, 1)
		elif last_direction == "left":
			direction_vector = Vector2(-1, 0)
		elif last_direction == "right":
			direction_vector = Vector2(1, 0)

	# Set animation parameters
	if sprinting:
		char_skin.set_animation_speed(sprint_anim_speed)
		char_skin.set_moving_speed(1.0)
	else:
		char_skin.set_animation_speed(normal_anim_speed)
		char_skin.set_moving_speed(0.0)

	char_skin.set_moving(input_direction != Vector2.ZERO)
	char_skin.set_direction(direction_vector)

	# Delegate footstep audio
	play_footsteps(input_direction, sprinting)

func play_footsteps(input_dir: Vector2, sprinting: bool) -> void:
	if input_dir != Vector2.ZERO:
		# Choose pitch based on sprint state
		if sprinting:
			FootstepsPlayer.pitch_scale = randf_range(1.1, 1.3)
		else:
			FootstepsPlayer.pitch_scale = randf_range(0.9, 1.1)

		if not FootstepsPlayer.playing:
			FootstepsPlayer.play()
	else:
		if FootstepsPlayer.playing:
			FootstepsPlayer.stop()

func _physics_process(_delta):
	if not GDSync.is_gdsync_owner(self):
		return

	var position_before = global_position
	get_input()
	move_and_slide()
	var position_after = global_position
	var delta_position = position_after - position_before
	var epsilon = 0.001
	if delta_position.length() < epsilon and velocity.length() > epsilon:
		global_position += get_wall_normal() * 0.1

func is_local_player() -> bool:
	return client_id == GDSync.get_client_id()
