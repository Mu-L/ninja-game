class_name Receptacle extends TextureRect

@onready var filling_difference: TextureRect = %FillingDifference
@onready var actual_filling: TextureRect = %ActualFilling

var current_amount: float = 1.0

func _ready() -> void:
	flash_difference(0.5)

func set_filling_amount(new_val: float) -> void:
	current_amount = new_val
	(actual_filling.material as ShaderMaterial).set_shader_parameter("water_level_percentage", new_val)

func set_difference_amount(new_val: float) -> void:
	(filling_difference.material as ShaderMaterial).set_shader_parameter("water_level_percentage", new_val)

var tween: Tween
func flash_difference(new_val: float) -> void:
	var prev_amount := current_amount
	set_difference_amount(prev_amount)
	set_filling_amount(new_val)
	$AnimationPlayer.play("flash")
