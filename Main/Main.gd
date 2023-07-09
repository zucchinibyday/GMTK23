extends Node2D

@onready var audio = $AudioStreamPlayer2D

func _ready():
	$Hero.connect("die", on_player_die)
	start_level()
	
func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE:
			get_tree().change_scene_to_file("res://TitleScreen/TitleScreen.tscn")
	
func on_player_die():
	for loaded_object in get_tree().get_nodes_in_group("loaded_objects"):
		loaded_object.queue_free()
		await loaded_object.tree_exited
	get_tree().reload_current_scene()

func start_level():
	audio.stream = load("res://Music/Knightfall_2.mp3")
	audio.play()
