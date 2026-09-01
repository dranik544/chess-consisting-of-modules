extends Label

onready var tween = $Tween
onready var board: Node2D = get_tree().get_first_node_in_group("board")

export(bool) var color


func _ready():
	Global.connect("turnChanged", self, "_on_turn_changed")
	_on_turn_changed()

func _on_turn_changed():
	text = "It is " + ("White" if Global.white_turn else "Black") + " turn to move"
	
	if !board: board = get_tree().get_first_node_in_group("board")
	if board && get_tree().network_peer != null:
		text += ("\n(Your turn)" if board.is_my_turn() else "\n(His turn)")
	
	if color == Global.white_turn:
		tween.interpolate_property(self, "modulate:a", modulate.a, 1.0, 0.5)
		tween.start()
	else:
		tween.interpolate_property(self, "modulate:a", modulate.a, 0.0, 0.25)
		tween.start()

