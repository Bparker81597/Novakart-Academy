class_name Seashell
extends Area3D

var collected := false
var start_height := 0.0
var time := 0.0

func _ready() -> void:
	start_height = position.y

func _process(delta: float) -> void:
	time += delta
	rotate_y(delta * 1.7)
	position.y = start_height + sin(time * 2.2) * 0.16

func _on_body_entered(body: Node3D) -> void:
	if collected or body.name not in ["HubPlayer", "PlayerKart"]:
		return
	collected = true
	var scene := get_tree().current_scene
	if scene and scene.has_method("collect_seashell"):
		scene.collect_seashell()
	elif body.has_method("collect_seashell"):
		body.collect_seashell()
	visible = false
	set_deferred("monitoring", false)
