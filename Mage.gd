extends CharacterBody2D

@onready var hero = get_node("/root/Main/Hero")



func _ready():
	pass
	

func _physics_process(delta):
	# Needs movement? Or just tags behind the hero
	position = Vector2(hero.position.x-30, hero.position.y)
	
	
