class_name VictoryScreen
extends Control

func show_victory(stars: int, total: int, new_stickers: Array[String] = []) -> void:
	visible = true
	$Celebration/StarScore.text = "★  %d / %d  ★" % [stars, total]
	$Celebration/NewSticker.visible = not new_stickers.is_empty()
	if not new_stickers.is_empty():
		var sticker := ContentCatalog.get_sticker(new_stickers[0])
		$Celebration/NewSticker.text = "NEW STICKER!  %s  %s" % [sticker.get("icon", "★"), sticker.get("name", "")]
	$Confetti.emitting = true
	$AnimationPlayer.play("celebrate")
	AudioManager.request_narration("victory")
	$Celebration/RaceAgain.grab_focus()

func _on_race_again_pressed() -> void:
	get_tree().reload_current_scene()

func _on_character_select_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/CharacterSelect.tscn")
