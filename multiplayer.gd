extends Node

func _ready():
	get_tree().connect("network_peer_connected", self, "_on_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_peer_disconnected")
	
	var args = OS.get_cmdline_args()
	if "--server" in args:
		server()
	elif "--client" in args:
		var ip = "127.0.0.1"
		for i in range(args.size() - 1):
			if args[i] == "--ip":
				ip = args[i+1]
				break
		client(ip)

func _on_peer_connected(id):
	print("Игрок ", id, " подключился!")
	rpc_id(id, "load_game_scene")
	
	for i in 60: yield(get_tree(), "idle_frame")
	
	get_tree().change_scene("res://scenes/main.tscn")

func _on_peer_disconnected(id: int):
	print("Игрок ", id, " отключился!")

func server():
	var peer = NetworkedMultiplayerENet.new()
	var error = peer.create_server(7777, 2)
	if error != OK:
		print("Ошибка создания сервера: ", error)
		return
	get_tree().network_peer = peer
	print("Сервер запущен на порту 7777, ждём игроков")

func client(ip = "127.0.0.1"):
	var peer = NetworkedMultiplayerENet.new()
	var error = peer.create_client(ip, 7777)
	if error != OK:
		print("Ошибка подключения: ", error)
		return
	get_tree().network_peer = peer
	print("Подключаемся к серверу ", ip, ":7777")

remote func load_game_scene():
	get_tree().change_scene("res://scenes/main.tscn")
