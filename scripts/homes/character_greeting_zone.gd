class_name CharacterGreetingZone
extends Area3D

func _on_body_entered(body: Node3D) -> void:
	if body.name != "HubPlayer":
		return
	var home := get_parent()
	if home and home.has_method("show_character_greeting"):
		home.show_character_greeting()
