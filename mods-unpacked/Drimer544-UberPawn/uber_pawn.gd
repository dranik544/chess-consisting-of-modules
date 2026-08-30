# uber_pawn.gd
extends "res://scripts/pieces/base_piece.gd"


func get_moves(board) -> Array:
	var moves = []
	var direction = Vector2(2, 0) if color else Vector2(-2, 0)
	var start_row = 1 if color else 6
	
	var forward = gridPos + direction
	if is_valid(forward) and is_empty(board, forward):
		moves.append(forward)
		if gridPos.x == start_row:
			var triple_forward = gridPos + direction * 3
			if is_valid(triple_forward) and is_empty(board, triple_forward):
				moves.append(triple_forward)
	
	for col_offset in [-1, 1]:
		var attack = gridPos + Vector2(direction.x, col_offset)
		if is_valid(attack) and is_enemy(board, attack):
			moves.append(attack)

	return moves

func on_move(board, from: Vector2, to: Vector2):
	if (color and to.x == 7) or (not color and to.x == 0):
		var queen_scene = load("res://scenes/pieces/queen.tscn")
		var queen = queen_scene.instance()
		if board.grid[to.x][to.y] != null:
			board.grid[to.x][to.y].queue_free()
			board.grid[to.x][to.y] = null
		queen.color = color
		queen.gridPos = to
		board.add_piece(queen, to)
		return queen
	return self
