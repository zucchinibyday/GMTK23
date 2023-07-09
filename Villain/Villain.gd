extends Area2D
class_name Villain

@export var state_controller: VillainStateController

@onready var rng := RandomNumberGenerator.new()

@onready var hero: Hero = get_tree().get_nodes_in_group("hero")[0]

func _ready():
	connect("body_entered", on_body_entered)
	ready_state()

@warning_ignore("unused_parameter")
func _process(delta):
	pass
	
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
	var anim_name: String
	var start: Callable
	var process: Callable
	var physics: Callable
	var stop: Callable
	var variables := {}
	
	func _init(
		_anim_name: String, 
		_start: Callable = Villain.__blank_start,
		_stop: Callable = Villain.__blank_stop,
		_process: Callable = Villain.__blank_process, 
		_physics: Callable = Villain.__blank_physics
	):
		anim_name = _anim_name
		start = _start
		stop = _stop
		process = _process
		physics = _physics
	
func ready_state():
	all_states.IDLE = (
		VillainState.new("idle", __idle_start, __blank_stop, __blank_process, __idle_physics)
	)
	all_states.SPELLCAST = (
		VillainState.new("spellcast", __spellcast_start)
	)
	all_states.SWAP = (
		VillainState.new("idle", __swap_start, __blank_stop, __blank_process, __swap_physics)
	)
	all_states.STAY = (
		VillainState.new("idle")
	)
	all_states.DECIDE_ATTACK = (
		VillainState.new("idle", __decide_start)
	)
	all_states.DASH = (
		VillainState.new("dash", __dash_start, __blank_stop, __blank_process, __dash_physics)
	)
	transition_state(all_states.SPELLCAST)

func transition_state(new_state: VillainState, old_state: VillainState = null):
	velocity = hero.velocity
	if old_state:
		old_state.stop.call(old_state, self)
	new_state.start.call(new_state, self)
	current_state = new_state
	
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
		transition_state(all_states.IDLE, state)
	
	body.velocity = Vector2(vx, 0) + body.hero.velocity

func __calc_swap_target(state, body) -> Vector2:
	return Vector2(
		body.hero.global_position.x + TARGET_REL_TO_HERO.x * state.variables.desired_side,
		body.hero.global_position.y + TARGET_REL_TO_HERO.y)

func __side_of_hero():
	return sign(global_position.x - hero.global_position.x)
	
	
func __decide_start(state, body):
	if !state.variables.attack_history:
		state.variables.attack_history = []
		return
	if !state.variables.attacK_history[0]:
		state.variables.attack_history.append("SPELLCAST")
		state.variables.attack_history.append("SPELLCAST")
		state.variables.attack_history.append("DASH")
		transition_state(all_states.SPELLCAST, state)
	else:
		var next_action = __decide_action(state.variables.attack_history)
		state.variables.attack_history.append(next_action)
		state.variables.attack_history.remove_at(0)
		transition_state(all_states[next_action], state)

func __decide_action(history: Array):
	var rval = ""
	if history[0] == history[2]:
		return "SPELLCAST"
	else:
		return history[2]

@warning_ignore("unused_parameter")
func __stay_start(state, body: Villain):
	await body.get_tree().create_timer(0.5).timeout
	transition_state(all_states.DECIDE_ATTACK, state)

@warning_ignore("unused_parameter")
func __dash_start(state: VillainState, body: Villain):
	body.velocity.y = 0
	state.variables.DASH_MODES = { "ALIGNING": 0, "DASHING": 1, "DONE": 2 }
	state.variables.dash_mode = state.variables.DASH_MODES.ALIGNING
	state.variables.target_y = body.hero.global_position.y
	state.variables.distance_to_align = abs(state.variables.target_y - body.global_position.y)
	
func __dash_physics(state: VillainState, body: Villain, delta: float):
	body.velocity = body.hero.velocity
	var DASH_MODES = state.variables.DASH_MODES
	match state.variables.dash_mode:
		DASH_MODES.ALIGNING:
			var progress = state.variables.distance_to_align - abs(state.variables.target_y - body.global_position.y)
			var step = progress / state.variables.distance_to_align
			var done = __align_for_dash(body, state.variables.target_y, step)
			if done:
				state.variables.dash_mode = DASH_MODES.DASHING

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

func __idle_physics(state, body: Villain, delta):
	state.variables.angle += TAU * delta / 2
	body.velocity = 128 * Vector2(
		-1 * (4.0 / 5.0) * sin(state.variables.angle),
		(3.0 / 5.0) * cos(state.variables.angle)
	)
	body.velocity.x += body.hero.velocity.x
	

func __spellcast_start(state, body):
	body.anim.play(state.anim_name)
	summon_orbs(rng.randi_range(2, 4))
	await anim.animation_finished
	transition_state(all_states.IDLE, state)

# attacks

@onready var orb_scene := preload("res://Villain/Attacks/Orb.tscn")

func summon_orbs(num: int):
	await get_tree().create_timer(0.9).timeout
	num = min(max(2, num), 8)
	for i in range(num + 1):
		var angle = (float(i) / float(num)) * TAU
		var pos = (24 * Vector2(cos(angle), sin(angle))) + global_position
		var new_orb = orb_scene.instantiate()
		get_parent().add_child.call_deferred(new_orb)
		new_orb.global_position = pos

# player interactions

@export var knockback_strength: int = 100

func on_body_entered(body):
	if body is Hero:
		var knockback_dir := Vector2(
			sign(body.global_position.x - global_position.x),
			(body.global_position - global_position).normalized().y
		)
		body.movement_controller.knockback(knockback_dir * 250)
		#body.take_damage(1)

# animation

@onready var anim = $AnimationPlayer
