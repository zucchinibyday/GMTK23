extends Node
class_name MovementScripter

@export var actors_movement_controller: MovementController
@export var actor: CharacterBody2D

var action_queue: Array[Action]
enum action_types { WALK, JUMP }
class Action:
	var action_type: int
	var duration: float
	var in_progress: bool = false
	var completed: bool = false
	func _init(_action_type: int, _duration: float):
		action_type = _action_type
		duration = _duration

func walk(duration_frames: float = 1):
	action_queue.append(Action.new(
		action_types.WALK,
		duration_frames
	))
	
func jump():
	action_queue.append(Action.new(
		action_types.JUMP,
		1
	))
	
func execute_action(action: Action):
	pass
	
func is_action_completed(action: Action):
	pass
	
func _process(delta):
	var current_action = action_queue[0]
	if !current_action.in_progress:
		current_action.in_progress = true
		execute_action(current_action)
		return
	if is_action_completed(current_action):
		current_action.mark_complete()
		action_queue.remove_at(0)
