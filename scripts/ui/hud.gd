class_name RaceHUD
extends Control

func set_star_count(value: int, total: int) -> void:
	$StarCount.text = "★  %d / %d" % [max(value, 0), total]
