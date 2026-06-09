extends Node3D

@export var building_name := "ACADEMY"
@export var building_icon := "★"
@export var primary_color := Color("6a45d9")
@export var accent_color := Color("ffd43b")

func _ready() -> void:
	$Sign.text = "%s  %s" % [building_icon, building_name]
	_apply_color($Body, primary_color)
	_apply_color($Roof, accent_color)
	_apply_color($Dome, accent_color.lightened(0.18))
	_apply_color($Awning, primary_color.lightened(0.22))
	_apply_color($BannerLeft, primary_color.darkened(0.12))
	_apply_color($BannerRight, primary_color.darkened(0.12))

func _apply_color(mesh: MeshInstance3D, color: Color) -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.72
	mesh.material_override = material
