class_name HubWorld
extends Node3D

var transition_locked := false

func _ready() -> void:
	$CanvasLayer/HUD/Welcome.text = "WELCOME, %s!" % ContentCatalog.get_character(SaveManager.get_selected_character()).get("name", "Racer").to_upper()
	$CanvasLayer/HUD/Home.grab_focus()
	AudioManager.request_narration("welcome_to_campus")

func show_activity(activity_name: String, target_scene: String) -> void:
	if transition_locked:
		return
	if not target_scene.is_empty():
		transition_locked = true
		get_tree().change_scene_to_file(target_scene)
		return
	$CanvasLayer/HUD/ActivityMessage/Label.text = "%s\nCOMING SOON!" % activity_name.to_upper()
	$CanvasLayer/HUD/ActivityMessage.visible = true
	get_tree().create_timer(2.5).timeout.connect(_hide_activity_message)

func _hide_activity_message() -> void:
	$CanvasLayer/HUD/ActivityMessage.visible = false

func _go_home() -> void:
	get_tree().change_scene_to_file("res://scenes/main/MainMenu.tscn")
