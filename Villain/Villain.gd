extends Area2D
class_name Villain

@onready var rng := RandomNumberGenerator.new()

@onready var hero: Hero = get_tree().get_nodes_in_group("hero")[0]

var anger: int = 0

func _ready():
	connect("body_entered", on_body_entered)
	ready_state()

@warning_ignore("unused_parameter")
func _process(delta):
	if rng.randf() <= delta:
		print("increase anger")
		anger += 1
	if Input.is_action_just_pressed("ui_up"):
		summon_orbs(1)
	process_state(delta)
	
func _physics_process(delta):
	physics_velocity(delta)
	physics_state(delta)

# basic velocity

var velocity := Vector2(0, 0)

func physics_velocity(delta):
	global_position += velocity * delta


# states

var current_state: VillainState

var all_states := {}

class VillainState:
	var state_name: String
	var anim_name: String
	var start: Callable
	var process: Callable
	var physics: Callable
	var stop: Callable
	var variables := {}
	
	func _init(
		_state_name: String,
		_anim_name: String, 
		_start: Callable = Villain.__blank_start,
		_stop: Callable = Villain.__blank_stop,
		_process: Callable = Villain.__blank_process, 
		_physics: Callable = Villain.__blank_physics
	):
		state_name = _state_name
		anim_name = _anim_name
		start = _start
		stop = _stop
		process = _process
		physics = _physics

# DO NOT CALL transition_state DURING THE START METHOD OF A STATE!! IT FUCKS SHIT UP

func ready_state():
	all_states.IDLE = (
		VillainState.new("IDLE", "idle", __idle_start, __blank_stop, __idle_process, __idle_physics)
	)
	all_states.SPELLCAST = (
		VillainState.new("SPELLCAST", "spellcast", __spellcast_start)
	)
	all_states.SWAP = (
		VillainState.new("SWAP", "idle", __swap_start, __blank_stop, __blank_process, __swap_physics)
	)
	all_states.REPOSITION_AND_ATTACK = (
		VillainState.new("REPOSITION_AND_ATTACK", "idle", __blank_start, __blank_stop, __blank_process, __reposition_and_attack_physics)
	)
	all_states.DECIDE_ATTACK = (
		VillainState.new("DECIDE_ATTACK", "idle", __blank_start, __blank_stop, __decide_process)
	)
	all_states.DASH = (
		VillainState.new('DASH', "dash", __dash_start, __blank_stop, __blank_process, __dash_physics)
	)
	all_states.REPOSITION = (
		VillainState.new('REPOSITION', "idle", __blank_start, __blank_stop, __blank_process, __reposition_physics)
	)
	transition_state(all_states.IDLE)

var transitioning := false

func transition_state(new_state: VillainState, old_state: VillainState = all_states.IDLE):
	#print("Transitioning from %s to %s" % [old_state.state_name, new_state.state_name])
	$Sprite2D.flip_h = __side_of_hero() == 1
	transitioning = true
	velocity = hero.velocity
	if old_state:
		old_state.stop.call(old_state, self)
	new_state.start.call(new_state, self)
	current_state = new_state
	transitioning = false
	
func process_state(delta):
	current_state.process.call(current_state, self, delta)
	
func physics_state(delta):
	current_state.physics.call(current_state, self, delta)


@warning_ignore("unused_parameter")
static func __blank_start(state, body):
	return
@warning_ignore("unused_parameter")
static func __blank_stop(state, body):
	return
@warning_ignore("unused_parameter")
static func __blank_process(state, body, delta):
	return
@warning_ignore("unused_parameter")
static func __blank_physics(state, body, delta):
	return
	

func __reposition_physics(state, body: Villain, delta):
	var target = body.hero.global_position + Vector2(__side_of_hero() * TARGET_REL_TO_HERO.x, TARGET_REL_TO_HERO.y)
	var new_pos = body.global_position.move_toward(
		target,
		0.95
	)
	body.global_position = new_pos
	if body.global_position == target:
		transition_state(all_states.IDLE, state)
	

func __reposition_and_attack_physics(state, body: Villain, delta):
	var target = body.hero.global_position + Vector2(__side_of_hero() * TARGET_REL_TO_HERO.x, TARGET_REL_TO_HERO.y)
	var new_pos = body.global_position.move_toward(
		target,
		0.95
	)
	body.global_position = new_pos
	if body.global_position == target:
		transition_state(all_states.DECIDE_ATTACK, state)


func __swap_start(state, body: Villain):
	state.variables.desired_side = -1 * __side_of_hero()
	state.variables.x_reached = false
	state.variables.y_reached = false
	
const TARGET_REL_TO_HERO := Vector2(128, -96)
const SWAP_VELOCITY := Vector2(96, 128)

func __swap_physics(state, body, delta):
	# please dont look at this
	# i just banged it together in the most unintelligent way until it worked
	var target = __calc_swap_target(state, body)
	
	var vx = (state.variables.desired_side * SWAP_VELOCITY.x)
	var dx_before_move = body.global_position.x - target.x
	var dx_after_move = (body.global_position.x + vx * delta) - target.x
	if sign(dx_before_move) != sign(dx_after_move):
		vx = 0
		body.global_position.x = target.x
		state.variables.x_reached = true
	
	if state.variables.x_reached:
		transition_state(all_states.DECIDE_ATTACK, state)
	
	body.velocity = Vector2(vx, 0) + body.hero.velocity

func __calc_swap_target(state, body) -> Vector2:
	return Vector2(
		body.hero.global_position.x + TARGET_REL_TO_HERO.x * state.variables.desired_side,
		body.hero.global_position.y + TARGET_REL_TO_HERO.y)

func __side_of_hero():
	return sign(global_position.x - hero.global_position.x)
	
	
func __decide_process(state, body, delta):
	var possible_actions = ["SPELLCAST", "DASH"]
	var next_action = possible_actions[rng.randi_range(0, len(possible_actions) - 1)]
	transition_state(all_states[next_action], state)

@warning_ignore("unused_parameter")
func __stay_start(state, body: Villain):
	await body.get_tree().create_timer(0.5).timeout
	transition_state(all_states.DECIDE_ATTACK, state)

@warning_ignore("unused_parameter")
func __dash_start(state: VillainState, body: Villain):
	anim.play("transform")
	anim.queue("dash")
	body.velocity.y = 0
	state.variables.DASH_MODES = { "ALIGNING": 0, "DASHING": 1, "DONE": 2 }
	state.variables.dash_mode = state.variables.DASH_MODES.ALIGNING
	state.variables.target_y = body.hero.global_position.y
	state.variables.distance_to_align = abs(state.variables.target_y - body.global_position.y)
	state.variables.dash_dir = -1 * __side_of_hero()
	
func __dash_physics(state: VillainState, body: Villain, delta: float):
	body.velocity = body.hero.velocity
	var DASH_MODES = state.variables.DASH_MODES
	match state.variables.dash_mode:
		DASH_MODES.ALIGNING:
			var progress = state.variables.distance_to_align - abs(state.variables.target_y - body.global_position.y)
			var step = progress / state.variables.distance_to_align
			var done = __align_for_dash(body, state.variables.target_y, step)
			if done:
				state.variables.dash_timer = body.get_tree().create_timer(1)
				body.get_child(3).disabled = false
				body.get_child(4).disabled = false
				state.variables.dash_mode = DASH_MODES.DASHING
				
		DASH_MODES.DASHING:
			if state.variables.dash_timer.time_left == 0:
				state.variables.dash_mode = DASH_MODES.DONE
			else:
				var step = 1 - (state.variables.dash_timer.time_left / 2)
				var mod_step = (-4 * step * step) + (4 * step)
				body.velocity.x += state.variables.dash_dir * 480 * mod_step
				
		DASH_MODES.DONE:
			body.velocity.x = body.hero.velocity.x
			body.anim.play_backwards("transform")
			body.anim.queue("idle")
			body.get_child(3).disabled = true
			body.get_child(4).disabled = true
			transition_state(all_states.REPOSITION, state)

func __align_for_dash(body: Villain, target_y, step):
	var new_pos = body.global_position.move_toward(
		Vector2(body.global_position.x, target_y),
		0.95
	)
	body.global_position = new_pos
	return global_position.y == target_y


func __idle_start(state, body):
	state.variables.angle = 0
	body.anim.play(state.anim_name)
	body.velocity = body.hero.velocity
	state.variables.timer = body.get_tree().create_timer(2)
	
func __idle_process(state, body, delta):
	if state.variables.timer.time_left == 0:
		var next_action = "SWAP" if rng.randf() > 0.5 else "REPOSITION_AND_ATTACK"
		transition_state(all_states[next_action], state)

func __idle_physics(state, body: Villain, delta):
	state.variables.angle += TAU * delta / 2
	body.velocity = 128 * Vector2(
		-1 * (4.0 / 5.0) * sin(state.variables.angle),
		(3.0 / 5.0) * cos(state.variables.angle)
	)
	body.velocity.x += body.hero.velocity.x
	

func __spellcast_start(state, body):
	body.anim.play(state.anim_name)
	summon_orbs(rng.randi_range(1 + (pow(anger, 0.5) / 2), 1 + pow(anger, 0.5)))
	await anim.animation_finished
	transition_state(all_states.IDLE, state)

# attacks

@onready var orb_scene := preload("res://Villain/Attacks/Orb.tscn")

func summon_orbs(num: int):
	await get_tree().create_timer(0.9).timeout
	num = clampi(num, 1, 8)
	for i in range(num):
		await get_tree().create_timer(rng.randf_range(0, 0.2)).timeout
		var angle = (float(i) / float(num)) * TAU
		var pos = (24 * Vector2(cos(angle), sin(angle))) + global_position
		var new_orb = orb_scene.instantiate()
		get_parent().add_child.call_deferred(new_orb)
		new_orb.global_position = pos

# player interactions

@export var knockback_strength: int = 100

func on_body_entered(body):
	if body is Hero:
		body.take_damage(2)

# animation

@onready var anim = $AnimationPlayer
