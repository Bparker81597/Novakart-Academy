class_name WaveRiderRaceManager
extends Node3D

const TOTAL_SHELLS := 8

@onready var player: KartController = $PlayerKart
var pending_rewards: Array[String] = []

func _ready() -> void:
	GameState.load_saved_character()
	GameState.reset_race()
	GameState.selected_track = "wave_rider_raceway"
	$FinishLine.race_finished.connect(_on_race_finished)
	$HUD.set_character_name(ContentCatalog.get_character(GameState.selected_character).get("name", "Racer"))
	$HUD.set_character_portrait(GameState.selected_character)
	$HUD.set_collectible_count("🐚", 0, TOTAL_SHELLS)

func collect_seashell() -> void:
	GameState.seashells += 1
	for reward: String in SaveManager.record_seashells(1):
		if reward not in pending_rewards:
			pending_rewards.append(reward)
	$HUD.set_collectible_count("🐚", GameState.seashells, TOTAL_SHELLS)

func _on_race_finished() -> void:
	if not player.can_drive:
		return
	player.can_drive = false
	for reward: String in SaveManager.record_coral_race(0, GameState.selected_character):
		if reward not in pending_rewards:
			pending_rewards.append(reward)
	$VictoryScreen.show_victory(GameState.seashells, TOTAL_SHELLS, pending_rewards)
