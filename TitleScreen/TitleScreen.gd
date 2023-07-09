extends Node2D
@onready var audio = $AudioStreamPlayer2D

var start_selected = true

@onready var start_selected_sprite = preload("res://TitleScreen/start_selected.png")
@onready var start_unselected_sprite = preload("res://TitleScreen/start_unselected.png")
@onready var quit_unselected_sprite = preload("res://TitleScreen/quit_unselected.png")
@onready var quit_selected_sprite = preload("res://TitleScreen/quit_selected.png")

func _ready():
	audio.stream = load("res://Music/WrongSideOfHistory_1.mp3")
	audio.play()

func _process(delta):
	if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_down"):
		start_selected = not start_selected
		$StartLabel.texture = start_selected_sprite if start_selected else start_unselected_sprite
		$QuitLabel.texture = quit_unselected_sprite if start_selected else quit_selected_sprite
	if Input.is_action_just_pressed("ui_select"):
		if start_selected:
			get_tree().change_scene_to_file("res://Main/Main.tscn")
		else:
			get_tree().quit()
	
