extends Sprite

const BOARD_SIZE: int = 8
const CELL_WIDTH: int = 18

# pieces index
# 6 = white king
# 5 = white queen
# 4 = white rook
# 3 = white bishop
# 2 = white knight
# 1 = white pawn
# 0 = null
# -6 = black king
# -5 = black queen
# -4 = black rook
# -3 = black bishop
# -2 = black knight
# -1 = black pawn

const WHITE_BISHOP: StreamTexture = preload("res://sprites/white_bishop.png")
const WHITE_KING: StreamTexture =   preload("res://sprites/white_king.png")
const WHITE_KNIGHT: StreamTexture = preload("res://sprites/white_knight.png")
const WHITE_PAWN: StreamTexture =   preload("res://sprites/white_pawn.png")
const WHITE_QUEEN: StreamTexture =  preload("res://sprites/white_queen.png")
const WHITE_ROOK: StreamTexture =   preload("res://sprites/white_rook.png")
const BLACK_BISHOP: StreamTexture = preload("res://sprites/black_bishop.png")
const BLACK_KING: StreamTexture =   preload("res://sprites/black_king.png")
const BLACK_KNIGHT: StreamTexture = preload("res://sprites/black_knight.png")
const BLACK_PAWN: StreamTexture =   preload("res://sprites/black_pawn.png")
const BLACK_QUEEN: StreamTexture =  preload("res://sprites/black_queen.png")
const BLACK_ROOK: StreamTexture =   preload("res://sprites/black_rook.png")

const WHITE_TURN: StreamTexture = preload("res://sprites/turn-white.png")
const BLACK_TURN: StreamTexture = preload("res://sprites/turn-black.png")
const PIECE_MOVE_DOT: StreamTexture = preload("res://sprites/Piece_move.png")

onready var pieces: Node2D = $pieces
onready var dots: Node2D = $dots
onready var turn: Sprite = $turn

var board: Array = [
	[ 4,  2,  3,  5,  6,  3,  2,  4],
	[ 1,  1,  1,  1,  1,  1,  1,  1],
	[ 0,  0,  0,  0,  0,  0,  0,  0],
	[ 0,  0,  0,  0,  0,  0,  0,  0],
	[ 0,  0,  0,  0,  0,  0,  0,  0],
	[ 0,  0,  0,  0,  0,  0,  0,  0],
	[-1, -1, -1, -1, -1, -1, -1, -1],
	[-4, -2, -3, -5, -6, -3, -2, -4],
]
var whiteTurn: bool = true
var state: bool
var moves: Array = []
var selectedPiece: Vector2
var totalSteps: int = 0


func _ready():
	_display_board()

func _input(event):
	if event is InputEventMouseButton && event.is_pressed():
		if _is_mouse_out(): return
		
		var pos: Vector2 = Vector2(
			floor(get_global_mouse_position().x / CELL_WIDTH),
			floor(-get_global_mouse_position().y / CELL_WIDTH)
		)
		
		print("Клик по ячейке: ", pos)
		if !state && (whiteTurn && board[pos.y][pos.x] > 0 || !whiteTurn && board[pos.y][pos.x] < 0):
			selectedPiece = Vector2(pos.y, pos.x)
			_show_options()
			state = true

func _is_mouse_out():
	if (
		get_global_mouse_position() < global_position + -Vector2(
			CELL_WIDTH * (BOARD_SIZE / 2),
			CELL_WIDTH * (BOARD_SIZE / 2)
		)
		||
		get_global_mouse_position() > Vector2(
			CELL_WIDTH * BOARD_SIZE,
			CELL_WIDTH * BOARD_SIZE
		)
	): return true

func _display_board():
	for iY in BOARD_SIZE:
		for iX in BOARD_SIZE:
			var textureHolder: Sprite = Sprite.new()
			pieces.add_child(textureHolder)
			textureHolder.position = Vector2(iX * CELL_WIDTH + (CELL_WIDTH / 2), -iY * CELL_WIDTH - (CELL_WIDTH / 2))
			
			match board[iY][iX]:
				6: textureHolder.texture = WHITE_KING
				5: textureHolder.texture = WHITE_QUEEN
				4: textureHolder.texture = WHITE_ROOK
				3: textureHolder.texture = WHITE_BISHOP
				2: textureHolder.texture = WHITE_KNIGHT
				1: textureHolder.texture = WHITE_PAWN
				-6: textureHolder.texture = BLACK_KING
				-5: textureHolder.texture = BLACK_QUEEN
				-4: textureHolder.texture = BLACK_ROOK
				-3: textureHolder.texture = BLACK_BISHOP
				-2: textureHolder.texture = BLACK_KNIGHT
				-1: textureHolder.texture = BLACK_PAWN
				
				_: textureHolder.texture = null

func _show_options():
	moves = _get_moves()
	if moves.empty():
		state = false
		return
	_show_dots()

func _show_dots():
	for i in moves:
		var textureHolder: Sprite = Sprite.new()
		dots.add_child(textureHolder)
		textureHolder.texture = PIECE_MOVE_DOT
		textureHolder.position = Vector2(i.y * CELL_WIDTH + (CELL_WIDTH / 2), -i.x * CELL_WIDTH - (CELL_WIDTH / 2))

func _get_moves():
	var _moves: Array = []
	match int(abs(board[int(selectedPiece.x)][int(selectedPiece.y)])):
		1: _moves = _get_pawn_moves()
		2: _moves = _get_knight_moves()
		3: _moves = _get_bishop_moves()
		4: _moves = _get_rook_moves()
		5: _moves = _get_queen_moves()
		6: _moves = _get_king_moves()
	
	return _moves

func _calculate_moves(directions: Array, once: bool):
	var _moves: Array = []
	for i in directions:
		var pos = selectedPiece
		pos += i
		
		if once:
			if _is_valid_position(pos):
				if   _is_empty(pos): _moves.append(pos)
				elif _is_enemy(pos):
					_moves.append(pos)
		else:
			while _is_valid_position(pos):
				if   _is_empty(pos): _moves.append(pos)
				elif _is_enemy(pos):
					_moves.append(pos)
					break
				else: break
				
				pos += i
	
	return _moves

func _get_rook_moves():
	var directions: Array = [
		Vector2(0, 1),
		Vector2(1, 0),
		Vector2(0, -1),
		Vector2(-1, 0),
	]
	
	return _calculate_moves(directions, false)

func _get_bishop_moves():
	var directions: Array = [
		Vector2(1, 1),
		Vector2(1, -1),
		Vector2(-1, -1),
		Vector2(-1, 1),
	]
	
	return _calculate_moves(directions, false)

func _get_queen_moves():
	var directions: Array = [
		Vector2(0, 1),
		Vector2(1, 1),
		Vector2(1, 0),
		Vector2(1, -1),
		Vector2(0, -1),
		Vector2(-1, -1),
		Vector2(-1, 0),
		Vector2(-1, 1),
	]
	
	return _calculate_moves(directions, false)

func _get_king_moves():
	var directions: Array = [
		Vector2(0, 1),
		Vector2(1, 1),
		Vector2(1, 0),
		Vector2(1, -1),
		Vector2(0, -1),
		Vector2(-1, -1),
		Vector2(-1, 0),
		Vector2(-1, 1),
	]
	
	return _calculate_moves(directions, true)

func _get_knight_moves():
	var directions: Array = [
		Vector2(1, -2),
		Vector2(2, -1),
		
		Vector2(2, 1),
		Vector2(1, 2),
		
		Vector2(-1, 2),
		Vector2(-2, 1),
		
		Vector2(-1, -2),
		Vector2(-2, -1),
	]
	
	return _calculate_moves(directions, true)

func _get_pawn_moves():
	var _moves = []
	var step = Vector2(1, 0) if whiteTurn else Vector2(-1, 0)
	var startRow = 1 if whiteTurn else 6
	
	var forward = selectedPiece + step
	if _is_valid_position(forward) and _is_empty(forward):
		_moves.append(forward)
		
		if selectedPiece.x == startRow:
			var double_forward = selectedPiece + step * 2
			if _is_valid_position(double_forward) and _is_empty(double_forward):
				_moves.append(double_forward)
	
	for i in [-1, 1]:
		var attack = selectedPiece + Vector2(step.x, i)
		if _is_valid_position(attack) and _is_enemy(attack):
			_moves.append(attack)
	
	return _moves

func _is_valid_position(pos: Vector2):
	if pos.x >= 0 && pos.x < BOARD_SIZE && pos.y >= 0 && pos.y < BOARD_SIZE: return true

func _is_empty(pos: Vector2):
	if board[pos.x][pos.y] == 0: return true

func _is_enemy(pos: Vector2):
	if (whiteTurn && board[pos.x][pos.y] < 0) || (!whiteTurn && board[pos.x][pos.y] > 0): return true
