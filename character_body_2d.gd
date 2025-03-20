extends CharacterBody2D

@export var speed: int = 500
@export var sprint_multiplier: float = 1.5
@export var normal_anim_speed: float = 1.0
@export var sprint_anim_speed: float = 1.5

var last_direction: String = "down"
var animated_sprite: AnimatedSprite2D

func _ready():
	animated_sprite = $AnimatedSprite2D

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
	get_input()
	move_and_slide()
	
#Hello

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
