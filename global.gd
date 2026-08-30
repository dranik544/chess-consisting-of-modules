# global.gd
extends Node

var white_turn = true
var totalSteps: int = 0

var preset: Dictionary = {
	"count give cards": 3,
}

var modPieces: Array = []
var modCards: Array = [
	load("res://scenes/cards/card_queen.tscn"),
]
