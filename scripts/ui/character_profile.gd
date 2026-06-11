class_name CharacterProfile
extends Control

const CHARACTER_IDS := ["blaze_bolt", "finn_tide", "nova_spark", "dash_rocket"]

var character_id := "nova_spark"

func _ready() -> void:
	character_id = GameState.profile_character
	_show_profile(character_id)
	$Actions/Back.grab_focus()

func _show_profile(new_character_id: String) -> void:
	character_id = new_character_id
	GameState.profile_character = character_id
	var profile := ContentCatalog.get_character(character_id)
	var color := Color(profile.get("color", "#a94dff"))
	$Portrait.configure(character_id, profile.get("theme", ""))
	$Details/Name.text = profile.get("name", "Nova Spark")
	$Details/Bio.text = profile.get("bio", "")
	$Details/Catchphrase/Value.text = "\"%s\"" % profile.get("catchphrase", "")
	$Details/Ability/Value.text = profile.get("ability", "")
	$Details/FavoriteActivity/Value.text = profile.get("favorite_activity", "")
	$Details/Name.add_theme_color_override("font_color", color)
	$FriendshipPanel.configure(character_id)
	AudioManager.play_character_greeting(character_id)

func _show_previous() -> void:
	var index := CHARACTER_IDS.find(character_id)
	_show_profile(CHARACTER_IDS[(index - 1 + CHARACTER_IDS.size()) % CHARACTER_IDS.size()])

func _show_next() -> void:
	var index := CHARACTER_IDS.find(character_id)
	_show_profile(CHARACTER_IDS[(index + 1) % CHARACTER_IDS.size()])

func _select_character() -> void:
	GameState.selected_character = character_id
	SaveManager.save_selected_character(character_id)
	get_tree().change_scene_to_file("res://scenes/main/CharacterSelect.tscn")

func _go_back() -> void:
	get_tree().change_scene_to_file("res://scenes/main/CharacterSelect.tscn")
