extends CanvasLayer

onready var buttons_menu = $buttons
onready var start_game_button = $"buttons/start game"
onready var ver = $buttons/ver
onready var tween = $Tween

onready var start_game_menu = $"start game menu"
onready var start_game_in_menu_button = $"start game menu/start game"
onready var host_game_button = $"start game menu/host game"
onready var connect_to_game_button = $"start game menu/connect to game"
onready var count_give_card_slider = $"start game menu/count give card/count give card"
onready var count_give_card_count_label = $"start game menu/count give card/count give card count"

onready var local_multiplayer_status_label = $"local multiplayer status/Label"

onready var warning_label = $warning/RichTextLabel
onready var warning_button = $warning/Button

var smiles_hehe: Array = [
	"?", "!", "...", ".", "!?",
	" ^w^", " :)", " :0", " :_(", " :P", " ;)", " :3",
	" -_-", " 0_0", " 9m9", " =w=", " =_=", " '_'", " -m-"
]


func _ready():
	Global.reset_game()
	Global.fade_animation(self, false)
	
	ver.text = Global.ver + "\nCreated by Drimer544"
	
	start_game_button.connect("pressed", self, "_on_start_game_button_pressed")
	
	start_game_in_menu_button.connect("pressed", self, "_on_start_game_in_menu_button_pressed")
	host_game_button.connect("pressed", self, "_on_host_game_button_pressed")
	connect_to_game_button.connect("pressed", self, "_on_connect_to_game_button_pressed")
	count_give_card_slider.connect("value_changed", self, "_on_count_give_card_slider_value_changed")
	warning_button.connect("pressed", self, "_on_warning_button_pressed")
	
	Global.connect("showWarning", self, "_show_warning")
	if !Global.warningText.empty():
		_show_warning()
	
	_on_count_give_card_slider_value_changed(count_give_card_slider.value)
	
	randomize()
	OS.set_window_title("Chess Consisting of Modules" + str(smiles_hehe.pick_random()))



func _on_start_game_button_pressed():
	start_game_menu.show()
	buttons_menu.hide()



func _on_start_game_in_menu_button_pressed():
	yield(Global.fade_animation(self, true), "completed")
	get_tree().change_scene("res://scenes/main.tscn")

func _on_host_game_button_pressed():
	LocalMultiplayer.server()
	start_game_menu.hide()
	show_local_multiplayer_status("Waiting for the player\n...")

func _on_connect_to_game_button_pressed():
	LocalMultiplayer.client()
	start_game_menu.hide()
	show_local_multiplayer_status("Searching for a server\n...")


func _on_count_give_card_slider_value_changed(value: float):
	count_give_card_count_label.text = str(value)
	Global.preset["count give cards"] = int(value)



func show_local_multiplayer_status(nText: String):
	local_multiplayer_status_label.get_parent().show()
	local_multiplayer_status_label.text = nText



func _show_warning():
	warning_label.get_parent().show()
	
	tween.interpolate_property(warning_label.get_parent(), "modulate:a", 0.0, 1.0, 0.5)
	tween.start()
	
	warning_label.bbcode_text = str(Global.warningText)
	Global.warningText = ""

func _on_warning_button_pressed():
	tween.interpolate_property(warning_label.get_parent(), "modulate:a", 1.0, 0.0, 0.5)
	tween.start()
	yield(tween, "tween_completed")
	
	warning_label.get_parent().hide()
