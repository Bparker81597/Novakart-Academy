class_name LapManager
extends Node

@export var total_laps: int = 3
var current_lap: int = 1

func complete_lap() -> bool:
	current_lap += 1
	return current_lap > total_laps
