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

remote func give_card(index: int, color: bool):
	if index < 0 or index >= Global.modCards.size(): return
	var card = Global.modCards[index]
	
	var whiteCardCount: int = 1
	var blackCardCount: int = 1
	for i in cards:
		whiteCardCount += 1 if i.color else 0
		blackCardCount += 1 if not i.color else 0
	
	if (color && whiteCardCount > maxCards) || (!color && blackCardCount > maxCards) || card == null: return
	
	var _card = card.instance()
	_card.color = color
	_card.card_index = cards.size()
	print("card index: " + str(_card.card_index))
	print("card color: " + str(_card.color))
	
	(white_container if color else black_container).add_child(_card)
	cards.append(_card)
	
	_card.flip_v = not color
	_card.connect("pressed", self, "_on_card_pressed", [_card.card_index, color])
	
	tween.interpolate_property(_card, "rect_position:y", 0.0 + (128.0 if color else -128.0), 0.0, 0.4, Tween.TRANS_BACK, Tween.EASE_OUT)
	tween.start()

func _on_card_pressed(index: int, color: bool):
	if index < 0 or index >= cards.size(): return
	if color != Global.white_turn: return
	var card = find_card(index, color)
	if card == null: print("карта не найдена"); return
	
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

func remove_card(index: int, color: bool):
	var card = find_card(index, color)
	if card == null: print("карта не найдена"); return
	
	cards.erase(card)
	
	tween.interpolate_property(card, "rect_scale", card.rect_scale, Vector2.ONE*3, 0.4, Tween.TRANS_CIRC, Tween.EASE_IN)
	tween.interpolate_property(card, "rect_rotation", card.rect_rotation, 15, 0.4, Tween.TRANS_CIRC, Tween.EASE_IN)
	tween.interpolate_property(card, "modulate:a", card.modulate.a, 0.0, 0.4)
	tween.start()
	yield(tween, "tween_all_completed")
	
	(white_container if color else black_container).remove_child(card)
	card.queue_free()

func find_card(index: int, color: bool):
	var card = null
	for i in cards:
		if i.card_index == index && i.color == color:
			card = i
			break
	
	print("карта не найдена" if card == null else "карта найдена")
	return card
