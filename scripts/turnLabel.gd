extends Label

onready var tween = $Tween

export(bool) var color


func _ready():
	Global.connect("turnChanged", self, "_on_turn_changed")
	_on_turn_changed()

func _on_turn_changed():
	text = "It is " + ("White" if Global.white_turn else "Black") + " turn to move"
	if color == Global.white_turn:
		tween.interpolate_property(self, "modulate:a", modulate.a, 1.0, 0.5)
		tween.start()
	else:
		tween.interpolate_property(self, "modulate:a", modulate.a, 0.0, 0.25)
		tween.start()
