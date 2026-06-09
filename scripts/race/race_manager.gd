class_name RaceManager
extends Node3D

@onready var player: KartController = $PlayerKart
@onready var hud: RaceHUD = $HUD

func _ready() -> void:
	GameState.reset_race()
	player.coin_collected.connect(_on_coin_collected)
	$FinishLine.race_finished.connect(_on_race_finished)
	hud.set_coin_count(0)

func _on_coin_collected() -> void:
	GameState.coins += 1
	hud.set_coin_count(GameState.coins)

func _on_race_finished() -> void:
	if not player.can_drive:
		return
	player.can_drive = false
	hud.show_finish(GameState.coins)
