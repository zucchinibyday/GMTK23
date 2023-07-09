extends Node2D

func _ready():
	$Hero.connect("die", on_player_die)
	
func on_player_die():
	for loaded_object in get_tree().get_nodes_in_group("loaded_objects"):
		loaded_object.queue_free()
		await loaded_object.tree_exited
	get_tree().reload_current_scene()
