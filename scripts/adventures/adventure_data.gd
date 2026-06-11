class_name AdventureData
extends Resource

@export var id := ""
@export var title := ""
@export var guide_character := ""
@export_multiline var intro_dialogue := ""
@export var objectives: Array[Dictionary] = []
@export var mission_id := ""
@export_multiline var completion_dialogue := ""
@export var destination_scene := ""
@export var rewards: Dictionary = {}
