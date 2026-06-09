class_name RaceManager
extends Node3D

signal race_started
signal race_finished

func start_race() -> void:
	race_started.emit()

func finish_race() -> void:
	race_finished.emit()
