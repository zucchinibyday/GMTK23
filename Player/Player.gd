extends CharacterBody2D

@onready var hero: Hero = get_node("/root/Main/Hero")
@export var movement_controller: MovementController

var independent_velocity: Vector2

func _ready():
	movement_controller.max_right_velocity = movement_controller.max_velocity
	movement_controller.max_left_velocity = 2 * movement_controller.max_velocity

func _physics_process(delta):
	if Input.is_action_pressed("fly_left"):
		movement_controller.accelerate("left")
	elif Input.is_action_pressed("fly_right"):
		movement_controller.accelerate("right")
	else:
		movement_controller.decelerate()
