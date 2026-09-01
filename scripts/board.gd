# board.gd
extends Node2D

const BOARD_SIZE: int = 8
const CELL_SIZE: int = 36
const PIECE_SCENES = {
	"PAWN": preload("res://scenes/pieces/pawn.tscn"),
	"ROOK": preload("res://scenes/pieces/rook.tscn"),
	"KNIGHT": preload("res://scenes/pieces/knight.tscn"),
	"BISHOP": preload("res://scenes/pieces/bishop.tscn"),
	"QUEEN": preload("res://scenes/pieces/queen.tscn"),
	"KING": preload("res://scenes/pieces/king.tscn")
}

onready var pieces_node: Node2D = $pieces
onready var dots_node: Node2D = $dots
onready var tween = $Tween
onready var cards: Node = get_tree().get_first_node_in_group("cards")
onready var camera: Node = get_tree().get_first_node_in_group("camera")

var grid = []
var defaultGrid: Array = []
var selected_piece = null
var legal_moves = []
var state = false

var placement_mode = false
var placement_card = null


func _ready():
	add_to_group("board")
	
	var p: Dictionary = PIECE_SCENES
	defaultGrid = [
		[p["ROOK"],p["KNIGHT"], p["BISHOP"], p["QUEEN"], p["KING"], p["BISHOP"], p["KNIGHT"], p["ROOK"]],
		[p["PAWN"], p["PAWN"], p["PAWN"], p["PAWN"], p["PAWN"], p["PAWN"], p["PAWN"], p["PAWN"]],
		[null, null, null, null, null, null, null, null],
		[null, null, null, null, null, null, null, null],
		[null, null, null, null, null, null, null, null],
		[null, null, null, null, null, null, null, null],
		[p["PAWN"], p["PAWN"], p["PAWN"], p["PAWN"], p["PAWN"], p["PAWN"], p["PAWN"], p["PAWN"]],
		[p["ROOK"],p["KNIGHT"], p["BISHOP"], p["QUEEN"], p["KING"], p["BISHOP"], p["KNIGHT"], p["ROOK"]],
	]
	
	init_grid()
	place_pieces()
	
	randomize()


func init_grid():
	grid = []
	for i in range(BOARD_SIZE):
		grid.append([])
		for j in range(BOARD_SIZE):
			grid[i].append(null)


func get_piece(pos: Vector2):
	if is_valid(pos):
		return grid[pos.x][pos.y]
	return null


func set_piece(pos: Vector2, piece):
	if is_valid(pos):
		grid[pos.x][pos.y] = piece


func is_empty(pos: Vector2) -> bool:
	return get_piece(pos) == null


func is_enemy(pos: Vector2, color: bool) -> bool:
	var p = get_piece(pos)
	return p != null and p.color != color


func is_valid(pos: Vector2) -> bool:
	return pos.x >= 0 and pos.x < BOARD_SIZE and pos.y >= 0 and pos.y < BOARD_SIZE


func get_pixel_position(pos: Vector2) -> Vector2:
	return Vector2(pos.y * CELL_SIZE + CELL_SIZE/2, -pos.x * CELL_SIZE - CELL_SIZE/2)


func get_grid_position(pixel: Vector2) -> Vector2:
	var col = floor((pixel.x + CELL_SIZE/2) / CELL_SIZE)
	var row = floor((-pixel.y + CELL_SIZE/2) / CELL_SIZE)
	return Vector2(row, col)


func place_pieces(setGrid: Array = defaultGrid):
	for y in range(setGrid.size()):
		for x in range(setGrid[y].size()):
			var piece_data = setGrid[y][x]
			if piece_data == null: continue
			var piece = piece_data.instance()
			
			piece.color = (y < 2)
			piece.gridPos = Vector2(y, x)
			piece.position = get_pixel_position(piece.gridPos)
			
			pieces_node.add_child(piece)
			grid[y][x] = piece


func add_piece(piece, pos: Vector2):
	piece.gridPos = pos
	piece.position = get_pixel_position(pos)
	pieces_node.add_child(piece)
	grid[pos.x][pos.y] = piece


func get_moves_for(piece) -> Array:
	if piece == null:
		return []
	if not piece.has_method("get_moves"):
		return []
	
	return piece.get_moves(self)


func get_legal_moves_for(piece) -> Array:
	var raw = get_moves_for(piece)
	var legal = []
	for move in raw:
		if simulate_move(piece, move):
			legal.append(move)
	
	return legal


func simulate_move(piece, to: Vector2) -> bool:
	var from = piece.gridPos
	var captured = get_piece(to)
	
	# Временно перемещаем
	grid[to.x][to.y] = piece
	grid[from.x][from.y] = null
	piece.gridPos = to
	piece.position = get_pixel_position(to)
	
	var king_pos = find_king(piece.color)
	var in_check = is_in_check(king_pos, piece.color)
	
	# Откат
	grid[from.x][from.y] = piece
	grid[to.x][to.y] = captured
	piece.gridPos = from
	piece.position = get_pixel_position(from)
	if captured:
		captured.gridPos = to
		captured.position = get_pixel_position(to)

	return not in_check


func find_king(color: bool) -> Vector2:
	for row in range(BOARD_SIZE):
		for col in range(BOARD_SIZE):
			var p = grid[row][col]
			if p != null and p.color == color and p.type == "king":
				return Vector2(row, col)
	
	return Vector2(-1, -1)


func is_in_check(king_pos: Vector2, color: bool) -> bool:
	var enemy_color = not color
	for row in range(BOARD_SIZE):
		for col in range(BOARD_SIZE):
			var p = grid[row][col]
			if p != null and p.color == enemy_color:
				var raw = get_moves_for(p)
				if king_pos in raw:
					return true
	
	return false


func make_move(from: Vector2, to: Vector2):
	var piece = get_piece(from)
	if piece == null: return
	
	var legal = get_legal_moves_for(piece)
	if not (to in legal): return
	
	var new_piece = piece.on_move(self, from, to)
	
	try_give_card()
	
	if new_piece != piece:
		grid[from.x][from.y] = null
		piece.queue_free()
	else:
		set_null_position(to)
		grid[to.x][to.y] = piece
		grid[from.x][from.y] = null
		piece.gridPos = to
		piece.move_animation(self, from, to)
#		piece.position = get_pixel_position(to)
	
	board_move_animation()
	Global.white_turn = not Global.white_turn
	Global.emit_signal("turnChanged")
	clear_dots()
	selected_piece = null
	state = false
	Global.totalSteps += 1
	
	check_game_state()


func set_null_position(pos: Vector2):
	if grid[pos.x][pos.y] != null:
		if grid[pos.x][pos.y].has_method("kill"):
			grid[pos.x][pos.y].kill()
			if camera == null: camera = get_tree().get_first_node_in_group("camera")
			camera.shake_screen()
		else:
			grid[pos.x][pos.y].queue_free()
		grid[pos.x][pos.y] = null


func try_give_card():
	if Global.totalSteps % Global.preset["count give cards"] == Global.preset["count give cards"]-1:
			if cards == null: cards = get_tree().get_first_node_in_group("cards")
			
			if cards:
				if !Global.modCards.empty():
					randomize()
					cards.give_card(Global.modCards[randi() % Global.modCards.size()], Global.white_turn)


func check_game_state():
	var current_color = Global.white_turn
	var king_pos = find_king(current_color)
	var in_check = is_in_check(king_pos, current_color)
	
	var has_legal = false
	for row in range(BOARD_SIZE):
		for col in range(BOARD_SIZE):
			var p = grid[row][col]
			if p != null and p.color == current_color:
				var moves = get_legal_moves_for(p)
				if not moves.empty():
					has_legal = true
					break
		if has_legal: break
	
	if !in_check:
		grid[king_pos.x][king_pos.y].checkLabel(false)
	elif in_check and not has_legal:
		grid[king_pos.x][king_pos.y].checkLabel(true)
		print("ШАХ И МАТ! Победили: ", "чёрные" if current_color else "белые")
	elif in_check:
		grid[king_pos.x][king_pos.y].checkLabel(true)
		print("ШАХ!")
	elif not has_legal:
		print("ПАТ! Ничья")


func clear_dots():
	for child in dots_node.get_children():
		child.queue_free()


func show_dots(moves: Array, full: bool):
	clear_dots()
	for pos in moves:
		var dot = Sprite.new()
		dot.texture = preload("res://sprites/dot.png")
		dot.position = get_pixel_position(pos)
		dot.modulate.a = 1.00 if full else 0.2
		dots_node.add_child(dot)


func on_click(cell: Vector2):
	if !is_valid(cell): return
	
	if placement_mode:
		if not is_valid(cell): return
		if not is_empty(cell): return
		if Global.white_turn and cell.x > 3: return
		if not Global.white_turn and cell.x < 4: return
		
		var piece = placement_card.piece.instance()
		piece.color = Global.white_turn
		add_piece(piece, cell)
		
		if cards == null:
			cards = get_tree().get_first_node_in_group("cards")
		
		if cards:
			cards.remove_card(placement_card, Global.white_turn)
		
		placement_mode = false
		placement_card = null
		clear_dots()
		
		Global.white_turn = not Global.white_turn
		Global.emit_signal("turnChanged")
		check_game_state()
		return
	
	if !state:
		var piece = get_piece(cell)
		if piece != null && piece.color == Global.white_turn:
			selected_piece = piece
			legal_moves = get_legal_moves_for(piece)
			if !legal_moves.empty():
				show_dots(legal_moves, true)
				state = true
			else:
				state = false
				clear_dots()
	else:
		if cell in legal_moves:
			make_move(selected_piece.gridPos, cell)
		else:
			var piece = get_piece(cell)
			if piece != null && piece.color == Global.white_turn:
				selected_piece = piece
				legal_moves = get_legal_moves_for(piece)
				if !legal_moves.empty():
					show_dots(legal_moves, true)
					state = true
				else:
					state = false
					clear_dots()
			else:
				state = false
				clear_dots()

func enter_placement_mode(card_instance, color: bool):
	if is_in_check(find_king(Global.white_turn), Global.white_turn):
		exit_placement_mode()
		return
	
	placement_mode = true
	placement_card = card_instance
	show_placement_zones()

func exit_placement_mode():
	placement_mode = false
	placement_card = null
	clear_dots()

func show_placement_zones():
	clear_dots()
	var start_row = 0 if Global.white_turn else 4
	var end_row = 3 if Global.white_turn else 7
	for row in range(start_row, end_row + 1):
		for col in range(8):
			var pos = Vector2(row, col)
			if is_empty(pos):
				var dot = Sprite.new()
				dot.texture = preload("res://sprites/dot.png")
				dot.position = get_pixel_position(pos)
				dot.modulate.a = 0.2
				dots_node.add_child(dot)

func board_move_animation():
	tween.interpolate_property(self, "scale", Vector2(1.0, 1.0), Vector2(0.99, 0.99), 0.04, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.interpolate_property(self, "scale", Vector2(0.99, 0.99), Vector2(1.0, 1.0), 0.3, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.1)
	tween.start()


func _input(event):
	if event is InputEventMouse:
		var board_origin = pieces_node.global_position
		var local_pos = get_global_mouse_position() - board_origin
		var col = floor(local_pos.x / CELL_SIZE)
		var row = floor(-local_pos.y / CELL_SIZE)
		
		if event is InputEventMouseMotion:
			var piece = get_piece(Vector2(row, col))
			if piece != null && !state && !placement_card:
				selected_piece = piece
				legal_moves = get_legal_moves_for(piece)
				if !legal_moves.empty() && !state && !placement_card:
					show_dots(legal_moves, false)
				elif legal_moves.empty() && !state && !placement_card:
					clear_dots()
			elif piece == null && !state && !placement_card:
				clear_dots()
		
		if event is InputEventMouseButton && event.is_pressed():
			if event.button_index == BUTTON_LEFT:
				if is_valid(Vector2(row, col)): on_click(Vector2(row, col))
