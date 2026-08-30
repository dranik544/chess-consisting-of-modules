# cards.gd
extends Node

onready var white_container = $white_cards
onready var black_container = $black_cards
onready var board: Node2D = get_tree().get_first_node_in_group("board")
onready var camera: Node2D = get_tree().get_first_node_in_group("camera")
onready var tween = $Tween

var cards = []
var maxCards: int = 4
var cardPressed: bool = false
var lastPressedCard


func _ready():
	add_to_group("cards")

func give_card(card: PackedScene, color: bool):
	if cards.size() > maxCards: return
	
	var _card: TextureButton = card.instance()
	_card.color = color
	
	(white_container if color else black_container).add_child(_card)
	cards.append(_card)
	
	_card.flip_v = not color
	_card.connect("pressed", self, "_on_card_pressed", [_card, color])
	
	tween.interpolate_property(_card, "modulate:a", 0.0, 1.0, 0.3)
	tween.interpolate_property(_card, "rect_scale:x", 0.0, 1.0, 0.3, Tween.TRANS_CIRC, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_completed")
	_card.flip_h = true
	tween.interpolate_property(_card, "rect_scale:x", 1.0, 0.0, 0.3, Tween.TRANS_CIRC, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_completed")
	_card.flip_h = false
	tween.interpolate_property(_card, "rect_scale:x", 0.0, 1.0, 0.3, Tween.TRANS_CIRC, Tween.EASE_IN_OUT)
	tween.start()

func _on_card_pressed(card, color: bool):
	if color != Global.white_turn: return
	
	if board:
		if lastPressedCard != card: cardPressed = true
		else: cardPressed = not cardPressed
		
		lastPressedCard = card
		
		if cardPressed:
			board.enter_placement_mode(card, color)
			card.focus_entered_animation()
		else:
			board.exit_placement_mode()
			card.focus_exited_animation()

func remove_card(card, color: bool):
	cards.erase(card)
	
	tween.interpolate_property(card, "rect_scale", card.rect_scale, Vector2.ONE*3, 0.4, Tween.TRANS_CIRC, Tween.EASE_IN)
	tween.interpolate_property(card, "rect_rotation", card.rect_rotation, 15, 0.4, Tween.TRANS_CIRC, Tween.EASE_IN)
	tween.interpolate_property(card, "modulate:a", card.modulate.a, 0.0, 0.4)
	tween.start()
	yield(tween, "tween_all_completed")
	
	(white_container if color else black_container).remove_child(card)
	card.queue_free()
