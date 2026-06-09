class_name HubWorld
extends Node3D

var transition_locked := false
var visual_time := 0.0

func _ready() -> void:
	$CanvasLayer/HUD/Welcome.text = "WELCOME, %s!" % ContentCatalog.get_character(SaveManager.get_selected_character()).get("name", "Racer").to_upper()
	$CanvasLayer/HUD/Home.grab_focus()
	AudioManager.request_narration("welcome_to_campus")

func _process(delta: float) -> void:
	visual_time += delta
	$Clouds/Cloud1.position.x = -14.0 + sin(visual_time * 0.11) * 2.5
	$Clouds/Cloud2.position.x = 8.0 + sin(visual_time * 0.09 + 1.5) * 3.0
	$Clouds/Cloud3.position.z = 2.0 + sin(visual_time * 0.12 + 2.4) * 2.0
	$FountainStar.position.y = 4.1 + sin(visual_time * 1.8) * 0.18
	$FountainStar.rotate_y(delta * 0.7)

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
