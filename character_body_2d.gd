class_name Player
extends CharacterBody2D

@export var speed: int = 500
@export var sprint_multiplier: float = 1.5
@export var normal_anim_speed: float = 1.0
@export var sprint_anim_speed: float = 1.5

@onready var _username: Label = $Username
@onready var _position_synchronizer = $PropertySynchronizer
@onready var char_skin = $Character/CharacterSkin

var last_direction: String = "down"

func _ready():
	# Ensure we have the correct reference to the CharacterSkin script.
	char_skin = $Character/CharacterSkin
	set_multiplayer_data.call_deferred()

func set_multiplayer_data():
	var client_id: int = name.to_int()
	_username.text = GDSync.get_player_data(client_id, "Username", "Unknown")
	_username.visible = !GDSync.is_gdsync_owner(self)

func get_input():
	var input_direction = Vector2.ZERO
	input_direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	var current_speed = speed
	var sprinting = false
	if Input.is_action_pressed("Sprint"):
		current_speed *= sprint_multiplier
		sprinting = true
		
	velocity = input_direction.normalized() * current_speed

	# Determine last movement direction for any additional logic you might need.
	if input_direction != Vector2.ZERO:
		if input_direction.x > 0:
			last_direction = "right"
		elif input_direction.x < 0:
			last_direction = "left"
		elif input_direction.y > 0:
			last_direction = "down"
		elif input_direction.y < 0:
			last_direction = "up"
	
	# Update the CharacterSkin with the current animation settings.
	char_skin.set_animation_speed(sprint_anim_speed if sprinting else normal_anim_speed)
	char_skin.set_moving(input_direction != Vector2.ZERO)
	char_skin.set_moving_speed(1.0 if sprinting else 0.0)  # 0.0 for walk, 1.0 for run

func _physics_process(_delta):
	if !GDSync.is_gdsync_owner(self): 
		return
	
	get_input()
	move_and_slide()
	
	var position_before := global_position
	var position_after := global_position
	var delta_position := position_after - position_before
	var epsilon := 0.001
	if delta_position.length() < epsilon and velocity.length() > epsilon:
		global_position += get_wall_normal() * 0.1
