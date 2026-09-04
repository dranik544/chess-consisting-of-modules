extends Camera2D

onready var board: Node2D = get_tree().get_first_node_in_group("board")

var shakeSensitivity: float = 0.0
var shakeDuration: float = 0.0


func _ready():
	add_to_group("camera")
	
	Global.connect("checkmate", self, "checkmate")

func shake_screen(sensitivity: float = 15.0, duration: float = 0.5):
	shakeSensitivity = sensitivity
	shakeDuration = duration

func _process(delta):
	if shakeSensitivity <= 0.0:
		offset = Vector2.ZERO
		return
	else:
		var randOffset: Vector2 = Vector2(
			rand_range(-shakeSensitivity, shakeSensitivity),
			rand_range(-shakeSensitivity, shakeSensitivity)
		)
		offset = lerp(offset, randOffset, 12 * delta)
		shakeSensitivity -= shakeDuration

func checkmate():
	shake_screen(40.0, 0.15)
