extends QuickTimeEvent

@onready var detection_area: Area2D = %DetectionArea
@onready var detection_area_shape: CollisionShape2D = %DetectionAreaShape
@onready var shuriken: Area2D = %Shuriken
@onready var path_follow_2d: PathFollow2D = %PathFollow2D
@onready var animation_player: AnimationPlayer = %AnimationPlayer

@export var radius: float

func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, Color.WHITE, false)

func _ready() -> void:
	assert(detection_area_shape.shape is CircleShape2D)
	(detection_area_shape.shape as CircleShape2D).radius = radius

func start(_ally) -> void:
	started = true
	animation_player.play("move shuriken")

func _process(_delta: float) -> void:
	if started and Input.is_action_just_pressed("interact"):
		animation_player.stop(true)
		var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE)
		tween.tween_property(shuriken, "scale", Vector2.ONE*1.5, 0.1)
		tween.tween_property(shuriken, "scale", Vector2.ONE, 0.25)
		await tween.finished
		
		var areas := detection_area.get_overlapping_areas()
		for area in areas:
			if area.is_in_group("shuriken"):
				finished.emit(true)
				self.queue_free()
				return
		finished.emit(false)
		self.queue_free()
