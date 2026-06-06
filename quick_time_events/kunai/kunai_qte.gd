extends QuickTimeEvent

@onready var cursor: Area2D = $Cursor
@onready var success_shape: CollisionShape2D = $SuccessArea/SuccessShape
@onready var success_area: Area2D = $SuccessArea
@onready var kunai: Area2D = %Kunai

var tween: Tween
var ally: AllyBattler
var target: EnemyBattler

func start(ally: AllyBattler) -> void:
	self.ally = ally
	target = ally.get_main_target_battler()
	started = true
	self.global_position = target.global_position
	kunai.global_position = ally.global_position
	kunai.look_at(target.global_position)
	cursor.global_position = target.global_position - Vector2(0, 100)
	tween = create_tween()
	tween.tween_property(cursor, "global_position", target.global_position + Vector2(0, 100), 3)
	tween.finished.connect(func():finished.emit())

func _process(_delta: float) -> void:
	if started and Input.is_action_just_pressed("interact"):
		tween.kill()
		if success_area in cursor.get_overlapping_areas():
			started = false
			var tween := create_tween()
			tween.tween_property(kunai, "global_position", target.global_position, 1.0)
			tween.finished.connect(func():
				finished.emit())

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
