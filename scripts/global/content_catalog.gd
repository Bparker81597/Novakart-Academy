extends Node

const CHARACTER_PATH := "res://data/characters.json"
const STICKER_PATH := "res://data/stickers.json"
const WORLD_PATH := "res://data/worlds.json"

var characters: Dictionary = {}
var stickers: Dictionary = {}
var worlds: Dictionary = {}

func _ready() -> void:
	characters = _load_by_id(CHARACTER_PATH, "characters")
	stickers = _load_by_id(STICKER_PATH, "stickers")
	worlds = _load_by_id(WORLD_PATH, "worlds")

func get_character(character_id: String) -> Dictionary:
	return characters.get(character_id, characters.get("nova_spark", {}))

func get_sticker(sticker_id: String) -> Dictionary:
	return stickers.get(sticker_id, {})

func get_all_stickers() -> Array:
	return stickers.values()

func get_world(world_id: String) -> Dictionary:
	return worlds.get(world_id, {})

func _load_by_id(path: String, collection_key: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("Could not load content: %s" % path)
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	var result := {}
	if parsed is Dictionary:
		for item: Variant in parsed.get(collection_key, []):
			if item is Dictionary and item.has("id"):
				result[item.id] = item
	return result
