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
	

@onready var game_tilemap = get_node("/root/Main/TileMap") 
@onready var ingame_mouse = get_node("MouseSprite")
@onready var hero = get_node("/root/Main/Hero")

@onready var past_hero_position = hero.position

#Mostly redundant, but have to be included. Framework for placing different types of files, remains unimplemented. Change seleceted_tile to change what you place.
#Due to how godot handles TileMaps, it'd be best by FAR to have a seperate tile for placed tiles, since that allows for them to be on a seperate collision layer.
@export var selected_tile: int = 2
@onready var output_tile: Tile


#screen jankiness means I can't just set it in the center
func _ready():
	ingame_mouse.position = hero.position

#manually moving the mouse with the autoscroll. Cringe, but oh well
func _process(delta):
	ingame_mouse.position += hero.position - past_hero_position
	past_hero_position = hero.position


func _unhandled_input(event):
	#captures mouse, places tile
	if event is InputEventMouseButton:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED && Input.is_action_just_pressed("mb_left"):
			place_tile_on_cursor()
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			
	#uncaptures mouse
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#Moves the mouse when you move your mouse (see: aforementioned screen jankiness forcing a questionable implementation)
	if event is InputEventMouseMotion:
		ingame_mouse.position += event.relative
			
#Could be cleaner. Done this way to allow potential expansion, but didn't end up having time to do so.
func place_tile_on_cursor():
	select_tile(game_tilemap.local_to_map(ingame_mouse.position))
	#places a NEW tile on layer THREE.
	game_tilemap.set_cell(output_tile.layer, output_tile.coords, output_tile.source_id, output_tile.atlas_coords, output_tile.alternative_title)
	
func select_tile(coords: Vector2i):
	output_tile = Tile.new(0,coords,selected_tile,Vector2i(0,0),0)
