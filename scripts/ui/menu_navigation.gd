class_name MenuNavigation
extends Control

func open_scene(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)

func quit_game() -> void:
	get_tree().quit()
