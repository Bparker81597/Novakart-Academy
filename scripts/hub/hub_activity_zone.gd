class_name HubActivityZone
extends Area3D

@export var activity_name := "Future Activity"
@export_file("*.tscn") var target_scene := ""

func _on_body_entered(body: Node3D) -> void:
	if body.name != "HubPlayer":
		return
	var hub := get_tree().current_scene
	if hub.has_method("show_activity"):
		hub.show_activity(activity_name, target_scene)
