class_name DialoguePanel
extends Control

signal continued

var character_id := ""

func _ready() -> void:
	visible = false

func show_dialogue(new_character_id: String, line: String) -> void:
	character_id = new_character_id
	var profile := ContentCatalog.get_character(character_id)
	$Card/Portrait.configure(character_id, "Adventure Guide")
	$Card/Name.text = profile.get("name", "Academy Guide")
	$Card/Text.text = line
	visible = true
	$Card.scale = Vector2(0.85, 0.85)
	$Card.modulate.a = 0.0
	create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).tween_property($Card, "scale", Vector2.ONE, 0.3)
	create_tween().tween_property($Card, "modulate:a", 1.0, 0.18)
	$Card/Continue.grab_focus()
	AudioManager.play_character_greeting(character_id)
	AudioManager.request_narration("adventure_dialogue_%s" % character_id)

func _continue() -> void:
	AudioManager.play_button_confirm()
	visible = false
	continued.emit()
