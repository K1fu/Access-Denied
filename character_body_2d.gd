extends CharacterBody2D

@export var speed: int = 500
@export var sprint_multiplier: float = 1.5
@export var normal_anim_speed: float = 1.0
@export var sprint_anim_speed: float = 1.5

@onready var _username: Label = $Username
@onready var _position_synchronizer = $PropertySynchronizer
@onready var _animation_synchronizer = $PropertySynchronizer2

var last_direction: String = "down"
var animated_sprite: AnimatedSprite2D

func _ready():
	animated_sprite = $AnimatedSprite2D
	set_multiplayer_data.call_deferred()

#hi.

func set_multiplayer_data():
	var client_id : int = name.to_int()
	
#	Display the username of this client
	_username.text = GDSync.get_player_data(client_id, "Username", "Unkown")
	
#	Make sure to only display the username of OTHER players, not yourself
	_username.visible = !GDSync.is_gdsync_owner(self)

func get_input():
	var input_direction = Vector2.ZERO
	input_direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	var current_speed = speed
	if Input.is_action_pressed("Sprint"):
		current_speed *= sprint_multiplier
		animated_sprite.speed_scale = sprint_anim_speed
	else:
		animated_sprite.speed_scale = normal_anim_speed
	
	velocity = input_direction.normalized() * current_speed

	# Store last movement direction
	if input_direction != Vector2.ZERO:
		if input_direction.x > 0:
			last_direction = "right"
		elif input_direction.x < 0:
			last_direction = "left"
		elif input_direction.y > 0:
			last_direction = "down"
		elif input_direction.y < 0:
			last_direction = "up"

func _physics_process(_delta):
	if !GDSync.is_gdsync_owner(self): return
	
	get_input()
	move_and_slide()
	var position_before := global_position
	var position_after := global_position
	
	var delta_position := position_after - position_before
	var epsilon := 0.001
	if delta_position.length() < epsilon and velocity.length() > epsilon:
		global_position += get_wall_normal() * 0.1

func _process(_delta):
	if velocity != Vector2.ZERO:
		if velocity.x > 0:
			animated_sprite.play("R_walking")
			animated_sprite.flip_h = false
		elif velocity.x < 0:
			animated_sprite.play("R_walking")
			animated_sprite.flip_h = true
		elif velocity.y > 0:
			animated_sprite.play("Down_walking")
		elif velocity.y < 0:
			animated_sprite.play("Top_walking")
	else:
		match last_direction:
			"right":
				animated_sprite.play("R_idle")
				animated_sprite.flip_h = false
			"left":
				animated_sprite.play("R_idle")
				animated_sprite.flip_h = true
			"down":
				animated_sprite.play("idle")
			"up":
				animated_sprite.play("Top_idle")
