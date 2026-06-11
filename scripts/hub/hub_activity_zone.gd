class_name HubActivityZone
extends Area3D

@export var activity_name := "Future Activity"
@export var prompt_text := "Coming Soon!"
@export var prompt_icon := "★"
@export var prompt_color := Color("8c42d6")
@export_file("*.tscn") var target_scene := ""

func _on_body_entered(body: Node3D) -> void:
	if body.name != "HubPlayer":
		return
	var hub := get_tree().current_scene
	if hub and hub.has_method("show_activity_prompt"):
		hub.show_activity_prompt(self)

func _on_body_exited(body: Node3D) -> void:
	if body.name != "HubPlayer":
		return
	var hub := get_tree().current_scene
	if hub and hub.has_method("hide_activity_prompt"):
		hub.hide_activity_prompt(self)
