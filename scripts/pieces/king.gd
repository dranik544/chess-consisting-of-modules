# king.gd
extends "res://scripts/pieces/base_piece.gd"


func get_moves(board) -> Array:
	var moves = []
	# Все 8 направлений
	var directions = [
		Vector2(0, 1),   # вверх
		Vector2(1, 1),   # вверх-вправо
		Vector2(1, 0),   # вправо
		Vector2(1, -1),  # вниз-вправо
		Vector2(0, -1),  # вниз
		Vector2(-1, -1), # вниз-влево
		Vector2(-1, 0),  # влево
		Vector2(-1, 1)   # вверх-влево
	]
	
	for d in directions:
		var pos = gridPos + d
		if is_valid(pos):
			# Можно пойти, если клетка пуста или на ней враг
			if is_empty(board, pos) or is_enemy(board, pos):
				moves.append(pos)
	
	return moves
