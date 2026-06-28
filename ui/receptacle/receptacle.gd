class_name Receptacle extends TextureRect

@onready var actual_filling: TextureRect = %ActualFilling

func update(new_val: float) -> void:
	(actual_filling.material as ShaderMaterial).set_shader_parameter("water_level_percentage", new_val)
