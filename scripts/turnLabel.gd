extends Label


func _ready():
	Global.connect("turnChanged", self, "_on_turn_changed")
	_on_turn_changed()

func _on_turn_changed():
	text = "It is " + ("White" if Global.white_turn else "Black") + " turn to move"
