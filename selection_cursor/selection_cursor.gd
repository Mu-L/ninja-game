class_name SelectionCursor extends Node2D

@onready var button_prompt_confirm: ButtonPrompt = $Sprite2D/ButtonPromptConfirm

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
	tween.tween_property(Global, "is_cursor_moving", true, 0.01)
	tween.tween_property(self, "global_position", pos, 0.15)
	tween.tween_property(Global, "is_cursor_moving", false, 0.01)

func hide_button_prompt() -> void:
	button_prompt_confirm.hide()

func show_button_prompt() -> void:
	button_prompt_confirm.show()
