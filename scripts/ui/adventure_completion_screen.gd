class_name AdventureCompletionScreen
extends Control

func _ready() -> void:
	visible = false
	SaveManager.adventure_completed.connect(show_adventure)

func show_adventure(adventure_id: String) -> void:
	var adventure := ContentCatalog.get_adventure(adventure_id)
	if not adventure:
		return
	var sticker := ContentCatalog.get_sticker(adventure.rewards.get("sticker", ""))
	var world := ContentCatalog.get_world(adventure.rewards.get("passport_stamp", ""))
	$Celebration/Portrait.configure(adventure.guide_character, "Adventure Guide")
	$Celebration/Title.text = "%s COMPLETE!" % adventure.title.to_upper()
	$Celebration/Dialogue.text = adventure.completion_dialogue
	$Celebration/Rewards.text = "🏅 %s BADGE   %s %s STICKER   📘 %s STAMP" % [
		adventure.rewards.get("badge", "hero").replace("_", " ").to_upper(),
		sticker.get("icon", "★"),
		sticker.get("name", "Adventure"),
		world.get("name", "World").to_upper(),
	]
	visible = true
	$Confetti.restart()
	$Celebration.scale = Vector2(0.12, 0.12)
	$Celebration.modulate.a = 0.0
	var tween := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property($Celebration, "modulate:a", 1.0, 0.15)
	tween.parallel().tween_property($Celebration, "scale", Vector2.ONE, 0.55)
	$Celebration/Continue.grab_focus()
	AudioManager.request_narration("adventure_complete_%s" % adventure_id)

func _continue() -> void:
	AudioManager.play_button_confirm()
	visible = false
