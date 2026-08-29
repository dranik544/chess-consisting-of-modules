# bishop.gd
extends "res://scripts/base_piece.gd"


func get_moves(board) -> Array:
	var moves = []
	var directions = [
		Vector2(1, 1),
		Vector2(1, -1),
		Vector2(-1, -1),
		Vector2(-1, 1)
	]
	
	for d in directions:
		var pos = gridPos + d
		while is_valid(pos):
			if is_empty(board, pos):
				moves.append(pos)
			elif is_enemy(board, pos):
				moves.append(pos)
				break
			else:
				break
			pos += d
	return moves
