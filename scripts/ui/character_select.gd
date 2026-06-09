class_name CharacterSelect
extends Control

const CHARACTER_IDS := ["blaze_bolt", "finn_tide", "nova_spark", "dash_rocket"]

var selected_character_id := "nova_spark"

func _ready() -> void:
	selected_character_id = SaveManager.get_selected_character()
	for index: int in CHARACTER_IDS.size():
		var character_id: String = CHARACTER_IDS[index]
		var card := $CharacterCards.get_child(index)
		card.configure(ContentCatalog.get_character(character_id), character_id == selected_character_id)
		card.character_selected.connect(_select_character)
		card.profile_requested.connect(_open_profile)
	_update_selected_banner()
	$Race.grab_focus()

func _select_character(character_id: String) -> void:
	selected_character_id = character_id
	GameState.selected_character = character_id
	SaveManager.save_selected_character(character_id)
	for index: int in CHARACTER_IDS.size():
		var card := $CharacterCards.get_child(index)
		card.set_selected(CHARACTER_IDS[index] == character_id)
	_update_selected_banner()
	AudioManager.play_character_greeting(character_id)

func _update_selected_banner() -> void:
	var profile := ContentCatalog.get_character(selected_character_id)
	$SelectedCharacter/Icon.text = profile.get("icon", "★")
	$SelectedCharacter/Name.text = profile.get("name", "Nova Spark")
	$SelectedCharacter/Theme.text = "%s  •  %s" % [profile.get("theme", ""), profile.get("ability", "")]
	$SelectedCharacter/Icon.modulate = Color(profile.get("color", "#a94dff"))

func _start_race() -> void:
	GameState.selected_character = selected_character_id
	SaveManager.save_selected_character(selected_character_id)
	get_tree().change_scene_to_file("res://scenes/race/RaceScene.tscn")

func _open_profile(character_id: String) -> void:
	GameState.profile_character = character_id
	get_tree().change_scene_to_file("res://scenes/main/CharacterProfile.tscn")

func _go_home() -> void:
	get_tree().change_scene_to_file("res://scenes/hub/HubWorld.tscn")
