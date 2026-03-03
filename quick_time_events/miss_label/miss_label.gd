class_name MissLabel extends Control

@onready var label: Label = %Label

signal bouncing_finished

func _ready() -> void:
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(label, "scale", Vector2.ONE*1.5, .25)
	tween.tween_property(label, "scale", Vector2.ONE, .4)
	await tween.finished
	bouncing_finished.emit()
	self.queue_free()
