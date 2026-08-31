extends Control

onready var bg = $bg
onready var label = $Label


func _ready():
	Global.connect("checkmate", self, "checkmate")

func checkmate():
	yield(get_tree().create_timer(0.5), "timeout")
	label.text = "Checkmate\n" + ("white" if not Global.white_turn else "black") + " won!"
	bg.modulate.a = 0.0
	label.modulate.a = 0.0
	show()
	
	var tween: Tween = Tween.new(); add_child(tween)
	tween.interpolate_property(bg, "modulate:a", bg.modulate.a, 0.8, 3.5)
	tween.interpolate_property(label, "modulate:a", label.modulate.a, 1.0, 1.0)
	tween.start()
	
	yield(tween, "tween_all_completed")
	yield(get_tree().create_timer(5.0), "timeout")
	
	get_tree().change_scene("res://scenes/menu.tscn")
