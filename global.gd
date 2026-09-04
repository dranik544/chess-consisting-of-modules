# global.gd
extends Node

var ver: String = "ver1t1"


signal turnChanged
signal checkmate
signal showWarning
var warningText: String

var white_turn = true
var totalSteps: int = 0
var myColor: bool

var preset: Dictionary = {
	"count give cards": 24,
}

const PIECE_SCENES = {
	"PAWN": preload("res://scenes/pieces/pawn.tscn"),
	"ROOK": preload("res://scenes/pieces/rook.tscn"),
	"KNIGHT": preload("res://scenes/pieces/knight.tscn"),
	"BISHOP": preload("res://scenes/pieces/bishop.tscn"),
	"QUEEN": preload("res://scenes/pieces/queen.tscn"),
	"KING": preload("res://scenes/pieces/king.tscn")
}
var modPieces: Dictionary = {}
var modCards: Array = [
	load("res://scenes/cards/card_queen.tscn"),
]
var cardData: Dictionary = {"white": [], "black": []}
var modGrid: Array = [
#	[null, null, null, null, PIECE_SCENES["KING"], null, null, null],
#	[null, null, null, null, PIECE_SCENES["PAWN"], null, null, null],
#	[null, null, null, null, null, null, null, null],
#	[null, null, null, null, null, null, null, null],
#	[null, null, null, null, null, null, null, null],
#	[null, null, null, null, null, null, null, null],
#	[null, null, null, null, null, null, null, null],
#	[PIECE_SCENES["ROOK"], PIECE_SCENES["KNIGHT"], PIECE_SCENES["QUEEN"], PIECE_SCENES["QUEEN"], PIECE_SCENES["QUEEN"], PIECE_SCENES["QUEEN"], PIECE_SCENES["KING"], PIECE_SCENES["ROOK"]],
]


func reset_game():
	cardData.clear()
	white_turn = true
	totalSteps = 0
	get_tree().network_peer = null

func _input(event):
	if event is InputEventKey:
		if   event.is_action_pressed("FULLSCREEN"): OS.window_fullscreen = not OS.window_fullscreen 
		elif event.is_action_pressed("BORDERLESS"): OS.window_borderless = not OS.window_borderless
		elif event.is_action_pressed("DEFAULT_WINDOW_SIZE"): OS.window_size = Vector2(640, 920)
		
		if event.is_action_pressed("MENU_MULTIPLAYER"):
			get_tree().change_scene("res://scenes/menu_multiplayer.tscn")
		elif event.is_action_pressed("RESTART_ALL"):
			reset_game()
			get_tree().change_scene("res://scenes/menu.tscn")
		elif event.is_action_pressed("RESTART_SCENE"):
			reset_game()
			get_tree().reload_current_scene()

func fade_animation(currentScene: Node, inout: bool, time: int = 0.5, color: Color = Color.black):
	var canvaslayer: CanvasLayer = CanvasLayer.new()
	var fade: ColorRect = ColorRect.new()
	fade.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	fade.color = color
	
	currentScene.add_child(canvaslayer)
	canvaslayer.add_child(fade)
	
	var tween: Tween = Tween.new()
	add_child(tween)
	
	if !inout: yield(get_tree().create_timer(0.1), "timeout")
	
	tween.interpolate_property(fade, "modulate:a",
		0.0 if inout else 1.0,
		1.0 if inout else 0.0,
		time
	); tween.start()
	
	if inout: yield(get_tree().create_timer(0.2), "timeout")
	
	yield(tween, "tween_completed")
	tween.queue_free()
	canvaslayer.queue_free()
	return true
