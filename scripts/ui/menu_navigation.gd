class_name MenuNavigation
extends Control

func _ready() -> void:
	$PlayButton.grab_focus()

func _on_play_pressed() -> void:
	open_scene("res://scenes/main/CharacterSelect.tscn")

func _on_stickers_pressed() -> void:
	open_scene("res://scenes/main/StickerBook.tscn")

func open_scene(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)

func quit_game() -> void:
	get_tree().quit()
