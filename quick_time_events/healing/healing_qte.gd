extends QuickTimeEvent

@export var qte_duration: float = 5.0

@onready var progress_bar: TextureProgressBar = %ProgressBar
@onready var timer: Timer = %Timer
@onready var time_left_label: Label = %TimeLeftLabel

func _ready() -> void:
	progress_bar.value = 0

func start(ally) -> void:
	started = true
	timer.start(qte_duration)

func _process(_delta: float) -> void:
	
	time_left_label.text = "%.2f" % timer.time_left
	
	if Input.is_action_just_pressed("interact") and started:
		var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(progress_bar, "value", progress_bar.value+5, 0.1)
		await tween.finished
	
	if progress_bar.value == progress_bar.max_value:
		started = false
		finished.emit(true)
		queue_free()
		return
	elif timer.is_stopped():
		started = false
		finished.emit(false)
		queue_free()
