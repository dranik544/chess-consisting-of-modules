# knight.gd
extends "res://scripts/base_piece.gd"


func get_moves(board) -> Array:
	var moves = []
	var offsets = [
		Vector2(1, -2), Vector2(2, -1),
		Vector2(2, 1),  Vector2(1, 2),
		Vector2(-1, 2), Vector2(-2, 1),
		Vector2(-2, -1), Vector2(-1, -2)
	]
	
	for off in offsets:
		var pos = gridPos + off
		if is_valid(pos) and (is_empty(board, pos) or is_enemy(board, pos)):
			moves.append(pos)
	return moves
