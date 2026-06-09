class_name HubWorld
extends Node3D

var transition_locked := false
var visual_time := 0.0
var nearby_activity: HubActivityZone

func _ready() -> void:
	var character_id := SaveManager.get_selected_character()
	var character_name: String = ContentCatalog.get_character(character_id).get("name", "Racer")
	$CanvasLayer/HUD/WelcomePanel/Portrait.configure(character_id)
	$CanvasLayer/HUD/WelcomePanel/Welcome.text = "WELCOME, %s!" % character_name.to_upper()
	$CanvasLayer/HUD/Home.focus_mode = Control.FOCUS_NONE
	AudioManager.request_narration("welcome_to_campus")

func _process(delta: float) -> void:
	visual_time += delta
	$Clouds/Cloud1.position.x = -14.0 + sin(visual_time * 0.11) * 2.5
	$Clouds/Cloud2.position.x = 8.0 + sin(visual_time * 0.09 + 1.5) * 3.0
	$Clouds/Cloud3.position.z = 2.0 + sin(visual_time * 0.12 + 2.4) * 2.0
	$FountainStar.position.y = 4.1 + sin(visual_time * 1.8) * 0.18
	$FountainStar.rotate_y(delta * 0.7)
	if nearby_activity and Input.is_action_just_pressed("boost"):
		_activate_nearby_activity()

func show_activity_prompt(activity: HubActivityZone) -> void:
	if transition_locked:
		return
	nearby_activity = activity
	$CanvasLayer/HUD/ActivityPrompt/Row/Icon.text = activity.prompt_icon
	$CanvasLayer/HUD/ActivityPrompt/Row/Prompt.text = activity.prompt_text
	var style: StyleBoxFlat = $CanvasLayer/HUD/ActivityPrompt.get_theme_stylebox("panel").duplicate()
	style.bg_color = activity.prompt_color
	style.border_color = activity.prompt_color.lightened(0.4)
	$CanvasLayer/HUD/ActivityPrompt.add_theme_stylebox_override("panel", style)
	$CanvasLayer/HUD/ActivityPrompt.visible = true
	$CanvasLayer/HUD/ActivityPrompt.scale = Vector2(0.7, 0.7)
	create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).tween_property($CanvasLayer/HUD/ActivityPrompt, "scale", Vector2.ONE, 0.24)

func hide_activity_prompt(activity: HubActivityZone) -> void:
	if nearby_activity != activity:
		return
	nearby_activity = null
	$CanvasLayer/HUD/ActivityPrompt.visible = false

func _activate_nearby_activity() -> void:
	if transition_locked or not nearby_activity:
		return
	AudioManager.play_button_confirm()
	if not nearby_activity.target_scene.is_empty():
		transition_locked = true
		get_tree().change_scene_to_file(nearby_activity.target_scene)
		return
	$CanvasLayer/HUD/ActivityMessage/Label.text = "%s\nCOMING SOON!" % nearby_activity.activity_name.to_upper()
	$CanvasLayer/HUD/ActivityMessage.visible = true
	get_tree().create_timer(2.5).timeout.connect(_hide_activity_message)

func _hide_activity_message() -> void:
	$CanvasLayer/HUD/ActivityMessage.visible = false

func _go_home() -> void:
	get_tree().change_scene_to_file("res://scenes/main/MainMenu.tscn")
