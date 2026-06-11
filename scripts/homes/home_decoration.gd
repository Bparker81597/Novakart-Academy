class_name HomeDecoration
extends Node3D

func configure(decoration: Dictionary, friendship_level: int, accent_color: Color) -> void:
	var required_level := int(decoration.get("required_friendship_level", 1))
	var unlocked := friendship_level >= required_level
	$Icon.text = decoration.get("icon", "★") if unlocked else "🔒"
	$Icon.modulate = accent_color if unlocked else Color(0.45, 0.48, 0.58, 1)
	$Label.text = decoration.get("label", "Home Decoration") if unlocked else "FRIENDSHIP LEVEL %d" % required_level
	$Label.modulate = Color.WHITE if unlocked else Color(0.75, 0.78, 0.86, 1)
	var material := StandardMaterial3D.new()
	material.albedo_color = accent_color if unlocked else Color(0.35, 0.38, 0.48, 1)
	$Pedestal.material_override = material
