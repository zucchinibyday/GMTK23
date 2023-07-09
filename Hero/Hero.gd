extends CharacterBody2D

@export var movement_controller: MovementController

@onready var ray = $RayCast2D 

enum FACING { LEFT = -1, RIGHT = 1}
var facing: FACING = FACING.RIGHT

func _ready():
	temp_ori_ready_code()
	process_core_startup()

var player_control_enabled := false

func _process(delta):
	if player_control_enabled:
		process_player_control(delta)
	else:
		process_ai_control(delta)
		
	temp_ori_process_code()
			
func process_player_control(delta):
	if Input.is_action_pressed("ui_right"):
		movement_controller.accelerate("right")
	elif Input.is_action_pressed("ui_left"):
		movement_controller.accelerate("left")
	else:
		movement_controller.decelerate()
	if Input.is_action_just_pressed("ui_up"):
		movement_controller.jump()
		#print(global_position)
		#print(movement_controller.distance_covered_during_jump())
		
func process_ai_control(delta):
	if !ray.is_colliding():
		#print("onward!")
		movement_controller.accelerate("right")
	else:
		if is_on_floor():
			movement_controller.jump()
			
			
func temp_ori_ready_code():
	ray.set_collision_mask_value(2,true)
	pass
			
func temp_ori_process_code():
	#ray.get_target_position(Vector2(0,0))
	#print(ray.get_collision_point())
	#print(ray.get_collider())
	pass
	





func process_core_startup():
	#Gives zach a headache
	
	
	
	pass
