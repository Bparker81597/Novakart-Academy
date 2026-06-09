class_name CharacterSelect
extends Control

const CHARACTER_IDS := ["blaze_bolt", "finn_tide", "nova_spark", "dash_rocket"]

var selected_character_id := "nova_spark"

func _ready() -> void:
	for character_id: String in CHARACTER_IDS:
		var button: Button = get_node("Drivers/%s" % _button_name(character_id))
		button.disabled = not SaveManager.is_character_unlocked(character_id)
	_show_profile(selected_character_id, false)
	$Drivers/Nova.grab_focus()

func _select_character(character_id: String) -> void:
	if not SaveManager.is_character_unlocked(character_id):
		return
	selected_character_id = character_id
	_show_profile(character_id, true)

func _show_profile(character_id: String, play_greeting: bool) -> void:
	var profile := ContentCatalog.get_character(character_id)
	$Profile/Icon.text = profile.get("icon", "★")
	$Profile/Name.text = profile.get("name", "Nova Spark")
	$Profile/Ability.text = profile.get("ability", "")
	$Profile/Catchphrase.text = "\"%s\"" % profile.get("catchphrase", "")
	$Profile/Icon.modulate = Color(profile.get("color", "#a94dff"))
	if play_greeting:
		AudioManager.play_character_greeting(character_id)

func _start_race() -> void:
	GameState.selected_character = selected_character_id
	get_tree().change_scene_to_file("res://scenes/race/RaceScene.tscn")

func _go_home() -> void:
	get_tree().change_scene_to_file("res://scenes/main/MainMenu.tscn")

func _button_name(character_id: String) -> String:
	return {
		"blaze_bolt": "Blaze",
		"finn_tide": "Finn",
		"nova_spark": "Nova",
		"dash_rocket": "Dash",
	}.get(character_id, "Nova")
