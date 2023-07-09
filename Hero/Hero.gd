extends CharacterBody2D
class_name Hero

@export var movement_controller: MovementController 

enum FACING { LEFT = -1, RIGHT = 1}
var facing: FACING = FACING.RIGHT

func _ready():
	add_to_group("loaded_object")
	add_to_group("hero")
	health_bar.update_health(health, max_health)
	anim.play("idle")
	
	movement_controller.connect("start_moving", on_start_moving)
	movement_controller.connect("stop_moving", on_stop_moving)
	movement_controller.connect("jumped", on_jump)
	movement_controller.connect("max_height_reached", on_max_height_reached)
	movement_controller.connect("hit_ground", on_hit_ground)

@export var player_control_enabled := false
@export var invincible := false

func _process(delta):
	if player_control_enabled:
		process_player_control(delta)
	else:
		process_ai_control(delta)
	update_visuals()
			
func process_player_control(delta):
	if Input.is_action_pressed("ui_right"):
		movement_controller.accelerate("right")
		facing = FACING.RIGHT
	elif Input.is_action_pressed("ui_left"):
		movement_controller.accelerate("left")
		facing = FACING.LEFT
	else:
		movement_controller.decelerate()
	if Input.is_action_just_pressed("ui_up"):
		movement_controller.jump()

@onready var wall_in_front_ray = $Rays/WallInFront
@onready var wall_on_top_ray = $Rays/WallOnTop

func process_ai_control(delta):
	print("-----")
	print(wall_in_front_ray.is_colliding())
	print(wall_on_top_ray.is_colliding())
	
	if !wall_in_front_ray.is_colliding():
		movement_controller.accelerate("right")
		
	if wall_in_front_ray.is_colliding() and !wall_on_top_ray.is_colliding():
		movement_controller.accelerate("right")
		movement_controller.jump()

	
@export_group("Health")
@export var health_bar: HealthBar
@export var max_health: int = 10
var health: int = max_health

signal die

func take_damage(amt: int):
	if invincible: 
		return
	health -= amt
	health_bar.update_health(health, max_health)
	if health <= 0:
		anim.clear_queue()
		anim.play("die")
		$CollisionShape2D.disabled = true
		await anim.animation_finished
		await get_tree().create_timer(0.8).timeout
		emit_signal("die")
		
@onready var anim = $AnimationPlayer

func update_visuals():
	$Sprite.flip_h = facing == FACING.LEFT

func on_start_moving():
	anim.clear_queue()
	anim.play("run_transition")
	anim.queue("run")

func on_stop_moving():
	anim.clear_queue()
	anim.play_backwards("run_transition")
	anim.queue("idle")

func on_jump():
	anim.clear_queue()
	anim.play("jump")

func on_max_height_reached():
	anim.clear_queue()
	anim.play("fall")

func on_hit_ground():
	anim.clear_queue()
	if movement_controller.is_walking:
		anim.play("run")
	else:
		anim.play("get_up")
		anim.queue("idle")
