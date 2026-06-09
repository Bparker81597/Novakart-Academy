class_name SettingsScreen
extends Control

func _ready() -> void:
	$Panel/Back.grab_focus()

func _on_voice_toggled(enabled: bool) -> void:
	AudioManager.voice_enabled = enabled

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/MainMenu.tscn")
