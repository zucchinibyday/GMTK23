extends CharacterBody2D

@onready var hero = get_node("/root/Main/Hero")



func _ready():
	pass
	

func _physics_process(delta):
	# Needs movement? Or just tags behind the hero
	global_position = Vector2(hero.global_position.x - 32, hero.position.y - 16)
	
	
