class_name CharacterSelect
extends Control

func _ready() -> void:
	$Drivers/Nova.grab_focus()

func _choose_character(character_id: String) -> void:
	GameState.selected_character = character_id
	get_tree().change_scene_to_file("res://scenes/race/RaceScene.tscn")
