extends Node

# ! Comments prefixed with "!" mean they are extra info. Comments without them
# ! should be kept because they give your mod structure and make it easier to
# ! read by other modders.

# --- Идентификаторы мода ---
# ! ВНИМАНИЕ: Это имя ДОЛЖНО строго совпадать с именем папки мода в res://mods-unpacked/
const DRIMER544_UBER_PAWN_DIR := "Drimer544-UberPawn"
const DRIMER544_UBER_PAWN_LOG_NAME := "Drimer544-UberPawn:Main"

var mod_dir_path := ""
var extensions_dir_path := ""
var translations_dir_path := ""

# --- Ресурсы мода ---
var uber_pawn_scene: PackedScene
var card_uber_pawn_scene: PackedScene


func _init() -> void:
	ModLoaderLog.info("Init", DRIMER544_UBER_PAWN_LOG_NAME)
	mod_dir_path = ModLoaderMod.get_unpacked_dir().plus_file(DRIMER544_UBER_PAWN_DIR)

	# --- Регистрация контента мода ---
	register_uber_pawn()

	# --- Добавление расширений скриптов ванильной игры ---
	install_script_extensions()

	# --- Добавление переводов/локализации ---
	add_translations()


func register_uber_pawn() -> void:
	# Загружаем сцены супер-пешки и её карты из папки мода
	uber_pawn_scene = load(mod_dir_path.plus_file("uber_pawn.tscn")) as PackedScene
	card_uber_pawn_scene = load(mod_dir_path.plus_file("card_uber_pawn.tscn")) as PackedScene
	
	if uber_pawn_scene == null:
		ModLoaderLog.error("Не удалось загрузить сцену uber_pawn.tscn!", DRIMER544_UBER_PAWN_LOG_NAME)
		return
	if card_uber_pawn_scene == null:
		ModLoaderLog.error("Не удалось загрузить сцену card_uber_pawn.tscn!", DRIMER544_UBER_PAWN_LOG_NAME)
		return


func install_script_extensions() -> void:
	# ! Любые расширения скриптов должны находиться в этой директории
	extensions_dir_path = mod_dir_path.plus_file("extensions")
	
	# Пример подключения расширения (раскомментируйте и измените имя, если используете):
	# ModLoaderMod.install_script_extension(extensions_dir_path.plus_file("main.gd"))
	pass


func add_translations() -> void:
	# ! Помещайте файлы ваших сгенерированных переводов (.translation) сюда
	translations_dir_path = mod_dir_path.plus_file("translations")
	
	# Пример подключения перевода (раскомментируйте, если используете):
	# ModLoaderMod.add_translation(translations_dir_path.plus_file("modname.en.translation"))
	pass


func _ready() -> void:
	ModLoaderLog.info("Ready", DRIMER544_UBER_PAWN_LOG_NAME)
	
	# Интеграция в глобальные массивы игры (убедитесь, что сцены были загружены успешно)
	if uber_pawn_scene != null:
		Global.modPieces.append(uber_pawn_scene)
	if card_uber_pawn_scene != null:
		Global.modCards.append(card_uber_pawn_scene)

	# Пример вывода переведенной строки в лог (если используется add_translations):
	# ModLoaderLog.info("Translation Demo: " + tr("MODNAME_READY_TEXT"), DRIMER544_UBER_PAWN_LOG_NAME)
