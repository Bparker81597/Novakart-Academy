class_name CoralCoastHub
extends Node3D

var nearby_activity: HubActivityZone
var transition_locked := false
var visual_time := 0.0

func _ready() -> void:
	SaveManager.visit_world("coral_coast")
	$CanvasLayer/HUD/FinnPortrait.configure("finn_tide", "Coral Coast Guide")
	_update_mission()
	$CanvasLayer/HUD/Home.focus_mode = Control.FOCUS_NONE
	AudioManager.play_character_greeting("finn_tide")

func _process(delta: float) -> void:
	visual_time += delta
	$Lighthouse/Beacon.rotate_y(delta * 1.2)
	$Coral/CoralLeft.position.y = 1.0 + sin(visual_time * 1.4) * 0.12
	$Coral/CoralRight.position.y = 1.0 + sin(visual_time * 1.4 + 1.2) * 0.12
	if nearby_activity and Input.is_action_just_pressed("boost"):
		_activate_nearby_activity()

func show_activity_prompt(activity: HubActivityZone) -> void:
	nearby_activity = activity
	$CanvasLayer/HUD/ActivityPrompt/Prompt.text = activity.prompt_text
	$CanvasLayer/HUD/ActivityPrompt/Icon.text = activity.prompt_icon
	$CanvasLayer/HUD/ActivityPrompt.visible = true

func hide_activity_prompt(activity: HubActivityZone) -> void:
	if nearby_activity == activity:
		nearby_activity = null
		$CanvasLayer/HUD/ActivityPrompt.visible = false

func _activate_nearby_activity() -> void:
	if transition_locked or not nearby_activity:
		return
	transition_locked = true
	AudioManager.play_button_confirm()
	get_tree().change_scene_to_file(nearby_activity.target_scene)

func _update_mission() -> void:
	$CanvasLayer/HUD/Mission.text = "FINN'S MISSION: HELP THE LIGHTHOUSE BEACON!"
	if SaveManager.has_passport_stamp("coral_coast"):
		$CanvasLayer/HUD/Passport.text = "PASSPORT  •  CORAL COAST  ✓"
	else:
		$CanvasLayer/HUD/Passport.text = "PASSPORT STAMP: COMPLETE THE MISSION"

func _go_home() -> void:
	get_tree().change_scene_to_file("res://scenes/hub/HubWorld.tscn")
