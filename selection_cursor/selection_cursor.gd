extends Node2D

func _ready() -> void:
	Global.move_cursor_to.connect(move_to)
	Global.set_cursor_visible.connect(func(val: bool):
		self.visible = val
	)

func move_to(pos: Vector2) -> void:
	var tween := (
		create_tween().
		set_ease(Tween.EASE_IN_OUT).
		set_trans(Tween.TRANS_CUBIC)
	)
	tween.tween_property(self, "global_position", pos, 0.1)
