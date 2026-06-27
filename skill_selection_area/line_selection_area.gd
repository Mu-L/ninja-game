extends SkillSelectionArea

func highlight_target(attacker: AllyBattler, target: Battler) -> void:
	self.global_position = attacker.global_position
	collision_shape_2d.shape.a = Vector2.ZERO
	var b: Vector2 = target.global_position - attacker.global_position
	collision_shape_2d.shape.b = b * 10
	queue_redraw()

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	draw_line(
		Vector2.ZERO,
		collision_shape_2d.shape.b,
		shape_color,
		1)
