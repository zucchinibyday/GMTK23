extends Area2D

var velocity: Vector2

@onready var anim = $AnimationPlayer

@onready var hero: Hero = get_tree().get_nodes_in_group("hero")[0]

func _ready():
	connect("body_entered", on_body_entered)
	anim.play("orb_appear")
	anim.queue("orb")
	await get_tree().create_timer(4.6).timeout
	disappear()
	
var is_disappearing = false
	
func disappear():
	is_disappearing = true
	anim.play("orb_disappear")
	await anim.animation_finished
	queue_free()

var lifetime := 0.0
var frames_till_max := 10.0
var rng = RandomNumberGenerator.new()

func _physics_process(delta):
	lifetime += 1
	if hero and !is_disappearing:
		var dir_to_hero = global_position.direction_to(hero.global_position)
		var step = lifetime / frames_till_max
		var mod_step = 1.0 - (2.0 / (step + 1))
		velocity = lerp(50, 300, mod_step) * dir_to_hero.normalized() + Vector2(hero.velocity.x, rng.randf_range(-16.0, 16.0))
	if is_disappearing:
		velocity *= 0.9
	position += velocity * delta

func on_body_entered(body): 
	if body is Hero:
		body.take_damage(1)
		disappear()
