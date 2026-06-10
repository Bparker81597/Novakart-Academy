class_name DiscoveryBeach
extends Node3D

var collected_here := 0

func _ready() -> void:
	$CanvasLayer/HUD/FinnPortrait.configure("finn_tide", "Discovery Guide")
	_update_counter()

func collect_seashell() -> void:
	collected_here += 1
	var rewards := SaveManager.record_seashells(1)
	_update_counter()
	if not rewards.is_empty():
		$CanvasLayer/HUD/StickerUnlockPopup.show_stickers(rewards)
		if SaveManager.has_badge("ocean_explorer"):
			$CanvasLayer/HUD/BadgeMessage.visible = true

func _update_counter() -> void:
	var mission_progress := int(SaveManager.progress.get("missions", {}).get("coral_shell_hunt", 0))
	$CanvasLayer/HUD/Counter.text = "🐚  SEASHELLS  %d / 5" % mission_progress

func _go_back() -> void:
	get_tree().change_scene_to_file("res://scenes/worlds/CoralCoastHub.tscn")
