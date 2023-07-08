extends Area2D

@export var state_controller: VillainStateController

func _ready():
	ready_state()

func _process(delta):
	pass
	
func _physics_process(delta):
	phys_process_velocity(delta)
	phys_process_state(delta)

# basic velocity

var velocity := Vector2(0, 0)

func phys_process_velocity(delta):
	global_position += velocity * delta

# states

var state: VillainState

var possible_states: Array[VillainState]

class VillainState:
	var anim_name: String
	var ready_behavior: Callable
	var process_behavior: Callable
	var physics_behavior: Callable
	var variables := {}
	
	func _init(
		_anim_name: String, 
		_ready_behavior: Callable = func():
			return, 
		_process_behavior: Callable = func():
			return, 
		_physics_behavior: Callable = func():
			return
	):
		anim_name = _anim_name
		ready_behavior = _ready_behavior
		process_behavior = _process_behavior
		physics_behavior = _physics_behavior
	
	
func ready_state():
	connect("body_entered", on_body_entered)
	possible_states.append(
		VillainState.new("idle", __idle_ready, __blank_process, __idle_physics_process)
	)
	state = possible_states[0]
	for _state in possible_states:
		_state.ready_behavior.call(_state, self)
	
func phys_process_state(delta):
	state.physics_behavior.call(state, self, delta)
	

func __blank_ready(state, body):
	return

func __blank_process(state, body, delta):
	return

func __blank_physics(state, body, delta):
	return
	

func __idle_ready(state, body):
	state.variables.angle = 0
	body.anim.play(state.anim_name)

func __idle_physics_process(state, body, delta):
	state.variables.angle += TAU * delta / 2
	velocity = 128 * Vector2(
		-1 * (3.0 / 5.0) * sin(state.variables.angle),
		(4.0 / 5.0) * cos(state.variables.angle)
	)

# player interactions

@export var knockback_strength: int = 100

func on_body_entered(body):
	if body is Hero:
		var knockback_dir: Vector2
		knockback_dir.x = sign(body.global_position.x - global_position.x)
		knockback_dir.y = (body.global_position - global_position).normalized().y
		body.movement_controller.knockback(knockback_dir * 250)
		body.take_damage(1)

# animation

@onready var anim = $AnimationPlayer
