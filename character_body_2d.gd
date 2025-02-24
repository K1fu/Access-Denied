extends CharacterBody2D

@export var speed: int = 500
@export var sprint_multiplier: float = 1.5 # Sprint speed multiplier
@export var normal_anim_speed: float = 1.0 # Normal animation speed
@export var sprint_anim_speed: float = 1.5 # Faster animation speed when sprinting

var last_direction: String = "down" # Track last direction (default is down)
var animated_sprite: AnimatedSprite2D

func _ready():
	animated_sprite = $AnimatedSprite2D

func get_input():
	var input_direction = Vector2.ZERO
	input_direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	# Check if sprint key is pressed
	var current_speed = speed
	if Input.is_action_pressed("Sprint"):
		current_speed *= sprint_multiplier
		animated_sprite.speed_scale = sprint_anim_speed # Increase animation speed
	else:
		animated_sprite.speed_scale = normal_anim_speed # Reset to normal speed
	
	velocity = input_direction.normalized() * current_speed

	# Store last movement direction
	if input_direction.x > 0:
		last_direction = "right"
	elif input_direction.x < 0:
		last_direction = "left"
	elif input_direction.y > 0:
		last_direction = "down"
	elif input_direction.y < 0:
		last_direction = "up"

func _physics_process(delta):
	get_input()
	move_and_slide()

func _process(delta):
	if Input.is_action_pressed("ui_right"):
		animated_sprite.play("R_walking")
		animated_sprite.flip_h = false
	elif Input.is_action_pressed("ui_left"):
		animated_sprite.play("R_walking")
		animated_sprite.flip_h = true
	elif Input.is_action_pressed("ui_down"):
		animated_sprite.play("Down_walking")
	elif Input.is_action_pressed("ui_up"):
		animated_sprite.play("Top_walking")
	else:
		# Play correct idle animation based on last direction
		match last_direction:
			"right", "left":
				animated_sprite.play("R_idle")
			"down":
				animated_sprite.play("idle") # Ensure you have a "Down_idle" animation
			"Top":
				animated_sprite.play("Top_idle")
