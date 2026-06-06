extends QuickTimeEvent

@onready var cursor: Area2D = %Cursor
@onready var success_shape: CollisionShape2D = $SuccessArea/SuccessShape
@onready var success_area: Area2D = $SuccessArea
@onready var kunai: Area2D = %Kunai
@onready var rotation_point: Node2D = $RotationPoint
@onready var spawn: Node2D = %Spawn

var tween: Tween

func start(ally: AllyBattler) -> void:
	super.start(ally)
	self.global_position = target.global_position
	kunai.global_position = ally.global_position
	kunai.look_at(target.global_position)
	
	rotation_point.rotation_degrees = randi_range(0, 360)
	cursor.global_position = spawn.global_position
	rotation_point.rotation_degrees += 180
	var final_pos := spawn.global_position
	tween = (create_tween().
		set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR))
	tween.tween_property(cursor, "global_position", final_pos, 1.5)
	tween.finished.connect(fail)

func _input(event: InputEvent) -> void:
	if started and event.is_action_pressed("interact"):
		tween.kill()
		started = false
		if success_area in cursor.get_overlapping_areas():
			var tween := create_tween()
			tween.tween_property(kunai, "global_position", target.global_position, 1.0)
			tween.finished.connect(func():
				finished.emit())
		else:
			fail()

func fail() -> void:
		await ally.missed_effect(target.global_position)
		finished.emit()

func _draw() -> void:
	draw_circle(
		Vector2.ZERO,
		(success_shape.shape as CircleShape2D).radius,
		Color.WHITE,
		false
	)

func _on_kunai_area_entered(area: Area2D) -> void:
	if area is EnemyBattler:
		area.take_damage(50)
