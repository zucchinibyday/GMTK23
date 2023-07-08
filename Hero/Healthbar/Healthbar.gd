extends Control
class_name HealthBar

@onready var HeartUIScene = preload("res://Hero/Healthbar/HeartUI.tscn")
@onready var FullHeartSprite = preload("res://Hero/Healthbar/heart.png")
@onready var HalfHeartSprite = preload("res://Hero/Healthbar/half_heart.png")

func update_health(amt: int):
	for heart in $Hearts.get_children():
		$Hearts.remove_child(heart)
	for i in range(floor(float(amt) / 2.0)):
		create_heartui(true)
	if amt % 2 == 1:
		create_heartui(false)

func create_heartui(full: bool):
	var heartui = HeartUIScene.instantiate()
	heartui.get_node("Sprite").texture = FullHeartSprite if full else HalfHeartSprite
	$Hearts.add_child(heartui)
