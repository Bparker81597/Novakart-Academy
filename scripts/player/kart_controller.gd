class_name KartController
extends CharacterBody3D

signal nova_star_collected

@export var drive_speed: float = 13.0
@export var reverse_speed: float = 5.0
@export var boost_speed: float = 19.0
@export var acceleration: float = 18.0
@export var steering_speed: float = 7.0
@export var track_half_width: float = 7.0

var can_drive: bool = true
var current_speed: float = 0.0

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
		current_speed = move_toward(current_speed, 0.0, acceleration * delta)
		velocity = Vector3(0.0, 0.0, -current_speed)
		move_and_slide()
		return

	var boosting := Input.is_action_pressed("boost") or Input.is_key_pressed(KEY_SPACE)
	var driving_forward := (
		Input.is_action_pressed("drive_forward")
		or Input.is_action_pressed("ui_up")
		or Input.is_key_pressed(KEY_UP)
		or boosting
	)
	var driving_reverse := (
		Input.is_action_pressed("brake")
		or Input.is_action_pressed("ui_down")
		or Input.is_key_pressed(KEY_DOWN)
	)
	var target_speed := 0.0
	if driving_forward:
		target_speed = boost_speed if boosting else drive_speed
	elif driving_reverse:
		target_speed = -reverse_speed
	current_speed = move_toward(current_speed, target_speed, acceleration * delta)

	var steering := Input.get_axis("steer_left", "steer_right")
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_LEFT):
		steering = -1.0
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_RIGHT):
		steering = 1.0
	velocity = Vector3(steering * steering_speed, 0.0, -current_speed)
	rotation.y = lerp(rotation.y, -steering * 0.18, delta * 7.0)
	$Body.rotation.z = lerp($Body.rotation.z, -steering * 0.08, delta * 7.0)
	move_and_slide()
	global_position.x = clamp(global_position.x, -track_half_width, track_half_width)

func collect_nova_star() -> void:
	nova_star_collected.emit()
