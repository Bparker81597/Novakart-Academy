class_name KartController
extends CharacterBody3D

@export var stats: KartStats

func _physics_process(delta: float) -> void:
	var acceleration := stats.acceleration if stats else 12.0
	var max_speed := stats.max_speed if stats else 24.0
	var input_direction := Input.get_axis("ui_down", "ui_up")
	velocity = velocity.move_toward(-transform.basis.z * input_direction * max_speed, acceleration * delta)
	move_and_slide()
