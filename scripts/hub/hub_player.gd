class_name HubPlayer
extends CharacterBody3D

@export var move_speed := 8.0
@export var campus_limit := Vector2(18.0, 14.0)

func _physics_process(_delta: float) -> void:
	var input := Input.get_vector("steer_left", "steer_right", "drive_forward", "brake")
	velocity = Vector3(input.x, 0.0, input.y) * move_speed
	move_and_slide()
	global_position.x = clamp(global_position.x, -campus_limit.x, campus_limit.x)
	global_position.z = clamp(global_position.z, -campus_limit.y, campus_limit.y)
	if velocity.length() > 0.1:
		rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), 0.18)
