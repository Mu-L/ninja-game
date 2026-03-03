extends QuickTimeEvent

@onready var progress_bar: TextureProgressBar = %ProgressBar

func _ready() -> void:
	progress_bar.value = 0

func start() -> void:
	started = true

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and started:
		var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(progress_bar, "value", progress_bar.value+5, 0.1)
		await tween.finished
	if progress_bar.value == progress_bar.max_value:
		started = false
		finished.emit(true)
		queue_free()
		return
