class_name RaceHUD
extends Control

func set_character_name(character_name: String) -> void:
	$CharacterName.text = character_name.to_upper()

func set_star_count(value: int, total: int) -> void:
	$StarCount.text = "★  %d / %d" % [max(value, 0), total]
