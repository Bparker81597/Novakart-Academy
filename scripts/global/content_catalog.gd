extends Node

const CHARACTER_PATH := "res://data/characters.json"
const STICKER_PATH := "res://data/stickers.json"
const WORLD_PATH := "res://data/worlds.json"
const MISSION_PATH := "res://data/missions.json"
const ADVENTURE_DIRECTORY := "res://data/adventures"
const FRIENDSHIP_PATH := "res://data/friendship.json"
const HOME_DIRECTORY := "res://data/homes"

var characters: Dictionary = {}
var stickers: Dictionary = {}
var worlds: Dictionary = {}
var missions: Dictionary = {}
var adventures: Dictionary = {}
var friendship: Dictionary = {}
var homes: Dictionary = {}

func _ready() -> void:
	characters = _load_by_id(CHARACTER_PATH, "characters")
	stickers = _load_by_id(STICKER_PATH, "stickers")
	worlds = _load_by_id(WORLD_PATH, "worlds")
	missions = _load_by_id(MISSION_PATH, "missions")
	adventures = _load_resources(ADVENTURE_DIRECTORY)
	friendship = _load_dictionary(FRIENDSHIP_PATH)
	homes = _load_resources(HOME_DIRECTORY)

func get_character(character_id: String) -> Dictionary:
	return characters.get(character_id, characters.get("nova_spark", {}))

func get_sticker(sticker_id: String) -> Dictionary:
	return stickers.get(sticker_id, {})

func get_all_stickers() -> Array:
	return stickers.values()

func get_world(world_id: String) -> Dictionary:
	return worlds.get(world_id, {})

func get_mission(mission_id: String) -> Dictionary:
	return missions.get(mission_id, {})

func get_adventure(adventure_id: String) -> AdventureData:
	return adventures.get(adventure_id)

func get_all_adventures() -> Array:
	return adventures.values()

func get_adventure_for_mission(mission_id: String) -> AdventureData:
	for adventure: AdventureData in adventures.values():
		if adventure.mission_id == mission_id:
			return adventure
	return null

func get_friendship_character(character_id: String) -> Dictionary:
	for character: Dictionary in friendship.get("characters", []):
		if character.get("id", "") == character_id:
			return character
	return {}

func get_friendship_source_xp(source_id: String) -> int:
	return int(friendship.get("sources", {}).get(source_id, 0))

func get_home(home_id: String) -> HomeData:
	return homes.get(home_id)

func get_home_for_character(character_id: String) -> HomeData:
	for home: HomeData in homes.values():
		if home.character_id == character_id:
			return home
	return null

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

func _load_resources(directory_path: String) -> Dictionary:
	var result := {}
	var directory := DirAccess.open(directory_path)
	if not directory:
		push_error("Could not load resource directory: %s" % directory_path)
		return result
	for filename: String in directory.get_files():
		if filename.get_extension() != "tres":
			continue
		var resource: Resource = load("%s/%s" % [directory_path, filename])
		if resource is AdventureData and not resource.id.is_empty():
			result[resource.id] = resource
		elif resource is HomeData and not resource.id.is_empty():
			result[resource.id] = resource
	return result

func _load_dictionary(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("Could not load content: %s" % path)
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	return parsed if parsed is Dictionary else {}
