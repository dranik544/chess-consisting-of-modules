extends CanvasLayer

onready var start_game_button = $"buttons/start game/Button"
onready var start_game_option_button = $"buttons/start game/OptionButton"


func _ready():
	start_game_option_button.add_item("OnePC Multiplayer")
	start_game_option_button.add_item("Local Multiplayer")
	
	start_game_button.connect("pressed", self, "_on_start_game_button_pressed")


func _on_start_game_button_pressed():
	get_tree().change_scene("res://scenes/main.tscn")
