extends QuickTimeEvent

@onready var cursor: Area2D = $Cursor
@onready var success_shape: CollisionShape2D = $SuccessArea/SuccessShape
var tween: Tween
@onready var success_area: Area2D = $SuccessArea
var ally: AllyBattler

func start(ally: AllyBattler) -> void:
	self.ally = ally
	started = true
	self.global_position = ally.target.global_position
	cursor.global_position = ally.target.global_position - Vector2(0, 100)
	tween = create_tween()
	tween.tween_property(cursor, "global_position", ally.target.global_position + Vector2(0, 100), 3)
	tween.finished.connect(func():
		finished.emit({}))

func _process(_delta: float) -> void:
	if started and Input.is_action_just_pressed("interact"):
		tween.kill()
		if success_area in cursor.get_overlapping_areas():
			var result: Dictionary[Battler, int] = {}
			result[ally.target] = 2
			for t in ally.targets:
				result[t] = 1
			finished.emit(result)

func _draw() -> void:
	draw_circle(
		Vector2.ZERO,
		(success_shape.shape as CircleShape2D).radius,
		Color.WHITE,
		false
	)
