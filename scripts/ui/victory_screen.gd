class_name VictoryScreen
extends Control

func show_victory(stars: int, total: int) -> void:
	visible = true
	$Panel/StarScore.text = "★  %d / %d" % [stars, total]
	$Panel/Again.grab_focus()

func _on_again_pressed() -> void:
	get_tree().reload_current_scene()

func _on_home_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/MainMenu.tscn")
