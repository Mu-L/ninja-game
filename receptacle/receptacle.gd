class_name Receptacle extends TextureRect

@onready var actual_filling: TextureRect = %ActualFilling

func update(new_val: float) -> void:
	#(actual_filling.material as ShaderMaterial).set_shader_parameter("water_level_percentage", new_val)
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(
		actual_filling.material,
		"shader_parameter/water_level_percentage",
		new_val,
		0.1
		)
	await tween.finished

func is_full() -> bool:
	var value: float = (actual_filling.material as ShaderMaterial).get_shader_parameter("water_level_percentage")
	value = min(1.0, value)
	return value == 1.0
