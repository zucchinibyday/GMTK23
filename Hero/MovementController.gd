extends Node
class_name MovementController

@export
var body: CharacterBody2D

var ignoring_input: bool = false

var is_falling: bool = false

func _physics_process(delta):
	if is_walking and !was_walking:
		emit_signal("start_moving")
		frames_since_start_walking = 0
		was_walking = true
	if !is_walking and was_walking:
		emit_signal("stop_moving")
		was_walking = false
		frames_since_start_walking = -1
	if is_walking and was_walking:
		frames_since_start_walking += 1
	
	if !body.is_on_floor():
		if jumping:
			frames_since_jump += 1
			if is_jump_over():
				emit_signal("max_height_reached")
				jumping = false
		else:
			is_falling = true
		body.velocity.y += gravity
	
	if is_falling and body.is_on_floor():
		emit_signal("hit_ground")
		is_falling = false
	
	body.move_and_slide()
	is_walking = false

@export_group("Run")
@export var max_velocity: float = 0
@export var time_till_maxv: float = 1
@onready var accel_x: float = max_velocity / (60 * time_till_maxv)
@export var time_till_stop: float = 1
@onready var decel_x: float = max_velocity / (60 * time_till_stop) if time_till_stop != 0 else 0
@export var momentum: float = 1

signal start_moving
signal stop_moving

var frames_since_start_walking: int = -1
var is_walking := false
var was_walking := false

func accelerate(dir_s: String):
	if ignoring_input:
		return
	is_walking = true
	var dir = 1 if dir_s == "right" else -1
	if sign(dir * accel_x) != sign(body.velocity.x):
		body.velocity.x = (body.velocity.x * momentum) + (dir * accel_x)
	else:
		body.velocity.x += dir * accel_x
	if abs(body.velocity.x) > max_velocity:
		body.velocity.x = sign(body.velocity.x) * max_velocity

func decelerate():
	# instant decel case
	if decel_x == 0:
		body.velocity.x = 0
		return
	# if decel would turn us around, just stop
	var old_velocity = body.velocity.x
	var new_velocity = old_velocity - (sign(old_velocity) * decel_x)
	if sign(new_velocity) != sign(old_velocity):
		body.velocity.x = 0
		return
	# normal case, still decelerating
	body.velocity.x = new_velocity

# currently doesnt work, we're just going with the "dumb" version of the ai for right now
func distance_covered_during_jump() -> float:
	print("START CALCULATION")
	var time_since_start_walk: float = float(frames_since_start_walking) / 60.0
	print(time_since_start_walk)
	
	if abs(body.velocity.x) == max_velocity:
		print("already at max velocity")
		return abs(body.velocity.x) * time_till_max_height
		
	if body.velocity.x == 0:
		print("starting from zero")
		if time_till_max_height <= time_till_maxv:
			return (accel_x * time_till_max_height * time_till_max_height) / 2
		else:
			return (
				(accel_x * time_till_maxv * time_till_maxv) / 2 +
				max_velocity * (time_till_max_height - time_till_maxv)
			)
			
	if abs(body.velocity.x) > 0 and abs(body.velocity.x) < max_velocity:
		print("between 0 and max velocity")
		if (time_till_maxv - time_since_start_walk) > time_till_max_height:
			return (accel_x / 2) * (
				(time_till_max_height * time_till_max_height) +
				(2 * time_till_max_height * time_since_start_walk)
			)
		else:
			return (
				accel_x * ((time_till_maxv * time_till_maxv) - (time_since_start_walk * time_since_start_walk)) +
				max_velocity * (time_till_max_height + time_since_start_walk - time_till_maxv)
			)
			
	return -1

@export_group("Jump")
@export var max_jump_height: float = 64
@export var time_till_max_height: float = 1
@onready var jump_velocity: float = (-2 * max_jump_height) / (time_till_max_height)
@onready var gravity: float = (2 * max_jump_height) / (time_till_max_height * time_till_max_height * 60)

signal jumped
signal max_height_reached
signal hit_ground

var jumping: bool = false
var frames_since_jump: int

func jump():
	if ignoring_input:
		return
	emit_signal("jumped")
	jumping = true
	frames_since_jump = 0
	body.velocity.y = jump_velocity

func is_jump_over():
	return frames_since_jump > time_till_max_height * 60



func reset_all_movement():
	body.velocity = Vector2.ZERO
	is_walking = false
	was_walking = false

func knockback(vector: Vector2):
	reset_all_movement()
	body.velocity = vector
	ignoring_input = true
	await get_tree().create_timer(1).timeout
	ignoring_input = false
