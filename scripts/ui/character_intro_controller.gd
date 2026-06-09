class_name CharacterIntroController
extends Control

var character_id := "nova_spark"
var theme_color := Color("#a94dff")

func _ready() -> void:
	character_id = GameState.intro_character
	if character_id.is_empty():
		character_id = SaveManager.get_selected_character()
	_show_character(character_id)
	_play_intro_animations()
	$Actions/StartAdventure.grab_focus()
	if SaveManager.unlock_academy_student_badge():
		$BadgePopup.celebrate()

func _show_character(new_character_id: String) -> void:
	character_id = new_character_id
	GameState.selected_character = character_id
	SaveManager.save_selected_character(character_id)
	var profile := ContentCatalog.get_character(character_id)
	theme_color = Color(profile.get("color", "#a94dff"))
	$Background.color = theme_color.lightened(0.78)
	$PortraitCard.configure(character_id)
	$Particles.configure(profile)
	$Identity/Row/Icon.text = profile.get("icon", "★")
	$Identity/Row/Icon.modulate = theme_color
	$Identity/Row/Text/Name.text = profile.get("name", "Nova Spark")
	$Identity/Row/Text/Type.text = profile.get("type", profile.get("theme", ""))
	$Identity/Row/Text/Name.add_theme_color_override("font_color", theme_color)
	$SpeechBubble.show_line(profile.get("intro_line", ""), theme_color)
	$Catchphrase/Text.text = "\"%s\"" % profile.get("catchphrase", "")
	$Catchphrase/Text.add_theme_color_override("font_color", theme_color.darkened(0.22))
	AudioManager.play_character_greeting(character_id)

func _play_intro_animations() -> void:
	$Identity.position.x -= 300.0
	create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).tween_property($Identity, "position:x", $Identity.position.x + 300.0, 0.55)
	var button := $Actions/StartAdventure
	var tween := create_tween().set_loops().set_trans(Tween.TRANS_SINE)
	tween.tween_property(button, "scale", Vector2(1.025, 1.025), 0.65)
	tween.tween_property(button, "scale", Vector2.ONE, 0.65)

func _start_adventure() -> void:
	AudioManager.play_button_confirm()
	AudioManager.play_catchphrase(character_id)
	get_tree().change_scene_to_file("res://scenes/hub/HubWorld.tscn")

func _choose_again() -> void:
	AudioManager.play_button_confirm()
	get_tree().change_scene_to_file("res://scenes/main/CharacterSelect.tscn")
