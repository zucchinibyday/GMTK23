extends Node

#Defines what a tile is. Surprised godot doesn't already have this. But makes it really pretty (mostly) to set tiles
class Tile:
	var layer: int
	var coords: Vector2i
	var source_id: int
	var atlas_coords: Vector2i
	var alternative_title: int
	
	#probably should implement getters and setters
	func _init(_layer: int, _coords: Vector2i, _source_id: int, _atlas_coords: Vector2i, _alternative_title: int):
		self.layer = _layer
		self.coords = _coords
		self.source_id = _source_id 
		self.atlas_coords = _atlas_coords
		self.alternative_title = _alternative_title
	

@onready var game_tilemap: TileMap = get_node("/root/Main/TileMap")
@onready var hero = get_node("/root/Main/Hero")

@onready var past_hero_position = hero.position

#Mostly redundant, but have to be included. Framework for placing different types of files, remains unimplemented. Change seleceted_tile to change what you place.
#Due to how godot handles TileMaps, it'd be best by FAR to have a seperate tile for placed tiles, since that allows for them to be on a seperate collision layer.
@export var selected_tile: int = 2
@onready var output_tile: Tile

func _input(event):
	# places tile
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("mb_left"):
			handle_mouse_click()

var player_tile_atlas = Vector2i(4, 1)
var empty_tile_atlas = Vector2i(-1, -1)

#Could be cleaner. Done this way to allow potential expansion, but didn't end up having time to do so.
func handle_mouse_click():
	var mouse_pos = game_tilemap.get_global_mouse_position()
	var tile_coords = Vector2i(floor(mouse_pos / 16.0))
	var current_tile_atlas = game_tilemap.get_cell_atlas_coords(0, tile_coords)
	print(current_tile_atlas)
	if current_tile_atlas == player_tile_atlas:
		remove_tile(tile_coords)
	elif current_tile_atlas == empty_tile_atlas:
		place_tile(tile_coords)

func place_tile(tile_coords: Vector2i):
	game_tilemap.set_cell(0, tile_coords, 0, player_tile_atlas, 0)

func remove_tile(tile_coords: Vector2i):
	game_tilemap.set_cell(0, tile_coords, 0, empty_tile_atlas, 0)
