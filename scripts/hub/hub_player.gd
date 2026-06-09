class_name HubPlayer
extends CharacterBody3D

@export var move_speed := 8.0
@export var campus_limit := Vector2(18.0, 14.0)
@export var camera_follow_speed := 5.0
@export var camera_offset := Vector3(0.0, 16.0, 13.0)

var idle_time := 0.0

func _ready() -> void:
	$CameraRig.top_level = true
	$CameraRig.global_position = global_position + camera_offset

func _process(delta: float) -> void:
	idle_time += delta
	if velocity.length() < 0.1:
		$Body.position.y = 1.0 + sin(idle_time * 2.2) * 0.08
		$Star.position.y = 2.25 + sin(idle_time * 2.2 + 0.7) * 0.12
	$Star.rotate_y(delta * 1.4)
	$CameraRig.global_position = $CameraRig.global_position.lerp(global_position + camera_offset, min(delta * camera_follow_speed, 1.0))

func _physics_process(_delta: float) -> void:
	var input := Input.get_vector("steer_left", "steer_right", "drive_forward", "brake")
	velocity = Vector3(input.x, 0.0, input.y) * move_speed
	move_and_slide()
	global_position.x = clamp(global_position.x, -campus_limit.x, campus_limit.x)
	global_position.z = clamp(global_position.z, -campus_limit.y, campus_limit.y)
	if velocity.length() > 0.1:
		rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), 0.18)
