class_name CharacterSkin
extends Node2D

@export var main_animation_player: AnimationPlayer

var moving_blend_path := "parameters/StateMachine/move/blend_position"

# False for idle; true for move.
@onready var moving: bool = false : set = set_moving

# Blend value between walk (0.0) and run (1.0).
@onready var move_speed: float = 0.0 : set = set_moving_speed
@onready var animation_tree = get_node("AnimationTree")
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	# Expose functions for multiplayer synchronization.
	GDSync.expose_func(set_moving)
	# Disable any direct input processing from here.
	set_process(false)

# Remove the _physics_process that was handling input directly to avoid conflicts.
# func _physics_process(delta):
#    [Removed: Animation is now controlled by Player.gd.]

# This function allows Player.gd to control the sprite's playback speed.
func set_animation_speed(new_speed: float):
	anim_sprite.speed_scale = new_speed

func set_moving(value: bool):
	# Synchronize the moving state across the network only if this is the local player.
	if moving != value and GDSync.is_gdsync_owner(self):
		GDSync.call_func(set_moving, [value])
	moving = value
	if moving:
		state_machine.travel("Walk")
	else:
		state_machine.travel("Idle")

var _broadcasted_speed: float = 0.0

func set_moving_speed(value: float):
	move_speed = clamp(value, 0.0, 1.0)
	animation_tree.set(moving_blend_path, move_speed)
	
	if abs(_broadcasted_speed - move_speed) > 0.1:
		_broadcasted_speed = move_speed
		if GDSync.is_gdsync_owner(self):
			GDSync.call_func(set_moving_speed, [value])
