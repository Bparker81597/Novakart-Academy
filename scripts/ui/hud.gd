class_name RaceHUD
extends Control

func set_coin_count(value: int) -> void:
	$CoinCount.text = "●  %d" % max(value, 0)

func show_finish(coins: int) -> void:
	$FinishPanel.visible = true
	$FinishPanel/Coins.text = "★  %d"
	$FinishPanel/Coins.text = $FinishPanel/Coins.text % coins
	$FinishPanel/Again.grab_focus()

func _on_again_pressed() -> void:
	get_tree().reload_current_scene()

func _on_home_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/MainMenu.tscn")
