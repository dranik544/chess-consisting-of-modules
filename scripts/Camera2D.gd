extends Camera2D

var shakeSensitivity: float = 0.0
var shakeDuration: float = 0.0


func _ready():
	add_to_group("camera")

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
		offset = lerp(offset, randOffset, 10 * delta)
		shakeSensitivity -= shakeDuration
