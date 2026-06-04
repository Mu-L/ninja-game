extends Node2D

@export var collision_shape_2d: CollisionShape2D 
@export var area_of_effect: SkillSelectionArea

func _draw() -> void:
	var shape := collision_shape_2d.shape
	area_of_effect.shape_color.a = 0.5
	var color = area_of_effect.shape_color
	if shape is CircleShape2D:
		draw_circle(Vector2.ZERO, shape.radius, Color.WHITE, false)
		draw_circle(Vector2.ZERO, shape.radius, color)
	elif shape is SegmentShape2D:
		draw_line(shape.a, shape.b, color)
