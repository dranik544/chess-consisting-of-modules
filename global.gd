# global.gd
extends Node

var ver: String = "ver1t1"


signal turnChanged
signal checkmate

var white_turn = true
var totalSteps: int = 0

var preset: Dictionary = {
	"count give cards": 16,
}

var modPieces = {}
var modCards: Array = [
	load("res://scenes/cards/card_queen.tscn"),
]
var cardData = {"white": [], "black": []}


func _input(event):
	if event is InputEventKey:
		if event.is_action_pressed("MENU_MULTIPLAYER"): get_tree().change_scene("res://scenes/menu_multiplayer.tscn")
		elif event.is_action_pressed("RESTART_ALL"): get_tree().change_scene("res://scenes/menu.tscn")
		elif event.is_action_pressed("RESTART_SCENE"): get_tree().reload_current_scene()
