extends Node

var selected_character: String = "nova_spark"
var profile_character: String = "nova_spark"
var intro_character: String = "nova_spark"
var selected_track: String = "sunny_speedway"
var nova_stars: int = 0
var seashells: int = 0

func reset_race() -> void:
	nova_stars = 0
	seashells = 0

func load_saved_character() -> void:
	selected_character = SaveManager.get_selected_character()
