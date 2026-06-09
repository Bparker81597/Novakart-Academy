class_name RaceHUD
extends Control

var coins: int = 0

func set_coin_count(value: int) -> void:
	coins = max(value, 0)
