extends Node2D

func _ready() -> void:
	Global.move_cursor_to.connect(move_to)
	Global.set_cursor_visible.connect(func(val: bool):
		self.visible = val
	)

func move_to(pos: Vector2) -> void:
	Global.is_cursor_moving = true
	var tween := (
		create_tween().
		set_ease(Tween.EASE_IN_OUT).
		set_trans(Tween.TRANS_CUBIC)
	)
	tween.tween_property(self, "global_position", pos, 0.15)
	tween.finished.connect(func(): Global.is_cursor_moving = false)
