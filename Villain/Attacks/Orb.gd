extends Area2D

var velocity: Vector2

@onready var anim = $AnimationPlayer

@onready var hero: Hero = get_tree().get_nodes_in_group("hero")[0]

func _ready():
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
	
func _physics_process(delta):
	if hero and !is_disappearing:
		var dir_to_hero = global_position.direction_to(hero.global_position)
		var dot = velocity.normalized().dot(dir_to_hero.normalized())
		velocity += dir_to_hero.normalized() / dir_to_hero.length()
	if is_disappearing:
		velocity *= 0.9
	position += velocity * delta
