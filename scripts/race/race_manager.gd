class_name RaceManager
extends Node3D

const TOTAL_STARS := 10

@onready var player: KartController = $PlayerKart
@onready var hud: RaceHUD = $HUD
@onready var victory_screen: VictoryScreen = $VictoryScreen

func _ready() -> void:
	GameState.reset_race()
	player.nova_star_collected.connect(_on_nova_star_collected)
	$FinishLine.race_finished.connect(_on_race_finished)
	hud.set_star_count(0, TOTAL_STARS)

func _on_nova_star_collected() -> void:
	GameState.nova_stars += 1
	hud.set_star_count(GameState.nova_stars, TOTAL_STARS)

func _on_race_finished() -> void:
	if not player.can_drive:
		return
	player.can_drive = false
	var new_stickers := SaveManager.record_race(GameState.nova_stars, GameState.selected_character)
	victory_screen.show_victory(GameState.nova_stars, TOTAL_STARS, new_stickers)
