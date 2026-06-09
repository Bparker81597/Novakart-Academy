class_name CharacterSelect
extends Control

const CHARACTER_IDS := ["blaze_bolt", "finn_tide", "nova_spark", "dash_rocket"]

var selected_character_id := "nova_spark"

func _ready() -> void:
	selected_character_id = SaveManager.get_selected_character()
	for character_id: String in CHARACTER_IDS:
		var card: Button = get_node("CharacterCards/%s" % _card_name(character_id))
		card.disabled = not SaveManager.is_character_unlocked(character_id)
	_update_selection(false)
	get_node("CharacterCards/%s" % _card_name(selected_character_id)).grab_focus()

func _select_character(character_id: String) -> void:
	if not SaveManager.is_character_unlocked(character_id):
		return
	selected_character_id = character_id
	SaveManager.save_selected_character(character_id)
	GameState.selected_character = character_id
	_update_selection(true)

func _update_selection(play_greeting: bool) -> void:
	var selected_profile := ContentCatalog.get_character(selected_character_id)
	for character_id: String in CHARACTER_IDS:
		var card: Button = get_node("CharacterCards/%s" % _card_name(character_id))
		card.button_pressed = character_id == selected_character_id
	$Selected.text = "★  %s  ★" % selected_profile.get("name", "Nova Spark")
	if play_greeting:
		AudioManager.play_character_greeting(selected_character_id)

func _start_race() -> void:
	SaveManager.save_selected_character(selected_character_id)
	GameState.selected_character = selected_character_id
	get_tree().change_scene_to_file("res://scenes/race/RaceScene.tscn")

func _go_home() -> void:
	get_tree().change_scene_to_file("res://scenes/main/MainMenu.tscn")

func _card_name(character_id: String) -> String:
	return {
		"blaze_bolt": "BlazeCard",
		"finn_tide": "FinnCard",
		"nova_spark": "NovaCard",
		"dash_rocket": "DashCard",
	}.get(character_id, "NovaCard")
