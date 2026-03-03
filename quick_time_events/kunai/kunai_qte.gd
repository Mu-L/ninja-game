extends QuickTimeEvent

@export var target_range: int = 10
@export var show_target_range: bool = false
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var kunai: Area2D = %Kunai

func start() -> void:
	started = true
	animation_player.play("move")

func _process(_delta: float) -> void:
	if started and Input.is_action_just_pressed("interact"):
		animation_player.stop(true)
		var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE)
		tween.tween_property(kunai, "scale", Vector2.ONE*1.5, 0.1)
		tween.tween_property(kunai, "scale", Vector2.ONE, 0.25)
		await tween.finished
		if kunai.position.y > -target_range and kunai.position.y < target_range:
			finished.emit(true)
			self.queue_free()
			return
		finished.emit(false)
		self.queue_free()

func _draw() -> void:
	if not show_target_range:
		return
	draw_line(
		Vector2(0, target_range),
		Vector2(0, -target_range),
		Color.RED
	)
