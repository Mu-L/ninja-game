class_name CircleSelectionArea extends SkillSelectionArea

func highlight_target(_attacker: AllyBattler, target: Battler) -> void:
	self.global_position = target.global_position
	for b in battlers:
		b.stop_blinking_animation()
		b.play_blinking_animation()

func _draw() -> void:
	var shape := collision_shape_2d.shape
	shape_color.a = 0.5
	draw_circle(Vector2.ZERO, shape.radius, Color.WHITE, false)
	draw_circle(Vector2.ZERO, shape.radius, shape_color)
