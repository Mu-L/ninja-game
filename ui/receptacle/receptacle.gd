class_name Receptacle extends TextureRect

@onready var actual_filling: TextureRect = %ActualFilling

func update(new_val: float) -> void:
	(actual_filling.material as ShaderMaterial).set_shader_parameter("water_level_percentage", new_val)

func is_full() -> bool:
	var value: float = (actual_filling.material as ShaderMaterial).get_shader_parameter("water_level_percentage")
	value = min(1.0, value)
	return value == 1.0
