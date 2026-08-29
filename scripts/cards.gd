# cards.gd
extends Node

onready var white_container = $white_cards
onready var black_container = $black_cards
onready var board: Node2D = get_tree().get_first_node_in_group("board")
onready var tween = $Tween

var cards = []


func _ready():
	add_to_group("cards")
	
	give_card(load("res://scenes/cards/card_queen.tscn"), true)
	give_card(load("res://scenes/cards/card_queen.tscn"), false)
	give_card(load("res://scenes/cards/card_queen.tscn"), true)
	give_card(load("res://scenes/cards/card_queen.tscn"), false)
	give_card(load("res://scenes/cards/card_queen.tscn"), true)
	give_card(load("res://scenes/cards/card_queen.tscn"), false)
	give_card(load("res://scenes/cards/card_queen.tscn"), true)
	give_card(load("res://scenes/cards/card_queen.tscn"), false)
	give_card(load("res://scenes/cards/card_queen.tscn"), true)
	give_card(load("res://scenes/cards/card_queen.tscn"), false)
	give_card(load("res://scenes/cards/card_queen.tscn"), true)
	give_card(load("res://scenes/cards/card_queen.tscn"), false)
	give_card(load("res://scenes/cards/card_queen.tscn"), true)
	give_card(load("res://scenes/cards/card_queen.tscn"), false)

func give_card(card: PackedScene, color: bool):
	var _card: TextureButton = card.instance()
	_card.color = color
	
	(white_container if color else black_container).add_child(_card)
	
	cards.append(_card)
	
	_card.connect("pressed", self, "_on_card_pressed", [_card, color])

func _on_card_pressed(card, color: bool):
	if color != Global.white_turn: return
	
	if board:
		board.enter_placement_mode(card, color)

func remove_card(card, color: bool):
	tween.interpolate_property(card, "rect_scale", card.rect_scale, Vector2.ONE*2, 0.25, Tween.TRANS_CIRC, Tween.EASE_IN)
	tween.interpolate_property(card, "modulate:a", card.modulate.a, 0.0, 0.25)
	tween.start()
	yield(tween, "tween_all_completed")
	
	cards.erase(card)
	(white_container if color else black_container).remove_child(card)
	
	card.queue_free()
