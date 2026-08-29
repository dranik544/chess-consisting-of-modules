# base_piece.gd
extends Node2D

export(String) var type
export(bool) var color             # true = белый, false = чёрный
export(Vector2) var gridPos        # позиция фигуры на доске
export(StreamTexture) var whiteSprite
export(StreamTexture) var blackSprite

onready var sprite: Sprite = $Sprite
onready var death_sprite = $death
onready var tween = $Tween


func _ready():
	if whiteSprite and blackSprite and sprite:
		sprite.texture = whiteSprite if color else blackSprite
	
	birth_animation()

func get_moves(board) -> Array:
	return []

func on_move(board, from: Vector2, to: Vector2):
	return self

func kill():
	yield(death_animation(), "completed")
	queue_free()


func move_animation(board, from: Vector2, to: Vector2):
	var _from: Vector2 = board.get_pixel_position(from)
	var _to: Vector2 = board.get_pixel_position(to)
	
	tween.interpolate_property(self, "position", _from, _to, 0.3, Tween.TRANS_BACK, Tween.EASE_OUT)
	tween.start()

func birth_animation():
	tween.interpolate_property(self, "scale", Vector2.ZERO, Vector2.ONE, 0.1, Tween.TRANS_CIRC, Tween.EASE_OUT)
	tween.start()

func death_animation():
	z_index = -1
	sprite.hide()
	death_sprite.rotation = rand_range(-0.5, 0.5)
	death_sprite.texture = load("res://sprites/white_death.png" if color else "res://sprites/black_death.png")
	
	tween.interpolate_property(death_sprite, "scale", Vector2.ONE*2, Vector2.ONE, 0.2, Tween.TRANS_CIRC, Tween.EASE_OUT)
	tween.start()
	
	yield(tween, "tween_completed")
	yield(get_tree().create_timer(20.0), "timeout")
	
	tween.interpolate_property(death_sprite, "modulate:a", death_sprite.modulate.a, 0.0, 10.0)
	tween.start()
	yield(tween, "tween_completed")

func is_valid(pos: Vector2) -> bool:
	return pos.x >= 0 and pos.x < 8 and pos.y >= 0 and pos.y < 8

func is_empty(board, pos: Vector2) -> bool:
	return board.get_piece(pos) == null

func is_enemy(board, pos: Vector2) -> bool:
	var p = board.get_piece(pos)
	return p != null and p.color != color
