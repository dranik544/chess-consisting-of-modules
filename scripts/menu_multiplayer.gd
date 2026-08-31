extends CanvasLayer

onready var host_game_button = $"buttons/host game"
onready var connect_to_game_button = $"buttons/connect to game"


func _ready():
	host_game_button.connect("pressed", self, "_on_host_game_button_pressed")
	connect_to_game_button.connect("pressed", self, "_on_connect_to_game_button_pressed")

func _on_host_game_button_pressed():
	LocalMultiplayer.server()

func _on_connect_to_game_button_pressed():
	LocalMultiplayer.client()
