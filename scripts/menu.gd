extends CanvasLayer

onready var start_game_button = $"buttons/start game"
onready var ver = $buttons/ver


func _ready():
	ver.text = Global.ver + "\nCreated by Drimer544"
	
	start_game_button.connect("pressed", self, "_on_start_game_button_pressed")


func _on_start_game_button_pressed():
	get_tree().change_scene("res://scenes/main.tscn")
