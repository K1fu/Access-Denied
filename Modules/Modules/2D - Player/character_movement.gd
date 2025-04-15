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
	GDSync.expose_func(set_direction)
	set_process(false)

# New function to update blend positions based on a direction vector.
func set_direction(direction: Vector2):
	# Update the blend positions for both Idle and Walk states.
	animation_tree.set("parameters/Idle/BlendSpace2D/blend_position", direction)
	animation_tree.set("parameters/Walk/BlendSpace2D/blend_position", direction)
	
	# Only broadcast if this is the local (owner) instance.
	if GDSync.is_gdsync_owner(self):
		GDSync.call_func(set_direction, [direction])

func set_animation_speed(new_speed: float):
	anim_sprite.speed_scale = new_speed

func set_moving(value: bool):
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
