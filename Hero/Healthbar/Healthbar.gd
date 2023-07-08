extends Control
class_name HealthBar

@onready var HeartUIScene = preload("res://Hero/Healthbar/HeartUI.tscn")
@onready var FullHeartSprite = preload("res://Hero/Healthbar/heart.png")
@onready var HalfHeartSprite = preload("res://Hero/Healthbar/half_heart.png")
@onready var EmptyHeartSprite = preload("res://Hero/Healthbar/empty_heart.png")

func update_health(amt: int, max: int):
	for heart in $Hearts.get_children():
		$Hearts.remove_child(heart)
	var num_full = floor(float(amt) / 2.0)
	var num_half = amt % 2
	var num_empty = floor(float(max - amt) / 2.0)
	for i in range(num_full):
		create_heartui("full")
	for i in range(num_half):
		create_heartui("half")
	for i in range(num_empty):
		create_heartui("empty")
	
func create_heartui(full: String):
	var heartui = HeartUIScene.instantiate()
	var sprite
	match full:
		"full":
			sprite = FullHeartSprite
		"half": 
			sprite = HalfHeartSprite
		"empty":
			sprite = EmptyHeartSprite
	heartui.get_node("Sprite").texture = sprite
	$Hearts.add_child(heartui)
