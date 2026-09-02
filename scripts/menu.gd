extends CanvasLayer

onready var buttons_menu = $buttons
onready var start_game_button = $"buttons/start game"
onready var ver = $buttons/ver

onready var start_game_menu = $"start game menu"
onready var start_game_in_menu_button = $"start game menu/start game"
onready var host_game_button = $"start game menu/host game"
onready var connect_to_game_button = $"start game menu/connect to game"
onready var count_give_card_slider = $"start game menu/count give card/count give card"
onready var count_give_card_count_label = $"start game menu/count give card/count give card count"

onready var local_multiplayer_status_label = $"local multiplayer status/Label"


func _ready():
	ver.text = Global.ver + "\nCreated by Drimer544"
	
	start_game_button.connect("pressed", self, "_on_start_game_button_pressed")
	
	start_game_in_menu_button.connect("pressed", self, "_on_start_game_in_menu_button_pressed")
	host_game_button.connect("pressed", self, "_on_host_game_button_pressed")
	connect_to_game_button.connect("pressed", self, "_on_connect_to_game_button_pressed")
	count_give_card_slider.connect("value_changed", self, "_on_count_give_card_slider_value_changed")
	
	_on_count_give_card_slider_value_changed(count_give_card_slider.value)



func _on_start_game_button_pressed():
	start_game_menu.show()
	buttons_menu.hide()



func _on_start_game_in_menu_button_pressed():
	get_tree().change_scene("res://scenes/main.tscn")

func _on_host_game_button_pressed():
	LocalMultiplayer.server()
	start_game_menu.hide()
	show_local_multiplayer_status("Ждём игрока\n...")

func _on_connect_to_game_button_pressed():
	LocalMultiplayer.client()
	start_game_menu.hide()
	show_local_multiplayer_status("Идёт поиск сервера\n...")


func _on_count_give_card_slider_value_changed(value: float):
	count_give_card_count_label.text = str(value)
	Global.preset["count give cards"] = int(value)



func show_local_multiplayer_status(nText: String):
	local_multiplayer_status_label.get_parent().show()
	local_multiplayer_status_label.text = nText
