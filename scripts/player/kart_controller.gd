class_name KartController
extends CharacterBody3D

signal coin_collected

@export var drive_speed: float = 11.0
@export var brake_speed: float = 4.0
@export var steering_speed: float = 7.0
@export var track_half_width: float = 5.0

var can_drive: bool = true

func _ready() -> void:
	var colors := {
		"blaze_bolt": Color("ff563d"),
		"finn_tide": Color("32a8ff"),
		"nova_spark": Color("a94dff"),
		"dash_rocket": Color("ffc928")
	}
	var material := StandardMaterial3D.new()
	material.albedo_color = colors.get(GameState.selected_character, colors["nova_spark"])
	$Body.material_override = material

func _physics_process(delta: float) -> void:
	if not can_drive:
		velocity = velocity.move_toward(Vector3.ZERO, 20.0 * delta)
		move_and_slide()
		return

	var speed := brake_speed if Input.is_action_pressed("brake") else drive_speed
	var steering := Input.get_axis("steer_left", "steer_right")
	velocity = Vector3(steering * steering_speed, 0.0, -speed)
	move_and_slide()
	global_position.x = clamp(global_position.x, -track_half_width, track_half_width)

func collect_coin() -> void:
	coin_collected.emit()
