extends QuickTimeEvent

@export var qte_duration: float = 5.0

@onready var progress_bar: TextureProgressBar = %ProgressBar
@onready var timer: Timer = %Timer
@onready var time_left_label: Label = %TimeLeftLabel
@onready var healing_sound: AudioStreamPlayer = %HealingSound

func _ready() -> void:
	progress_bar.value = 0

func start(ally: AllyBattler) -> void:
	super.start(ally)
	timer.start(qte_duration)

func _process(_delta: float) -> void:
	
	if not started:
		return
	
	time_left_label.text = "%.2f" % timer.time_left
	
	if Input.is_action_just_pressed("interact"):
		var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(progress_bar, "value", progress_bar.value+5, 0.1)
		await tween.finished
	
	if progress_bar.value == progress_bar.max_value:
		started = false
		healing_sound.play()
		await ally.get_main_target_battler().heal(randi_range(40,60))
		finished.emit()
	elif timer.is_stopped():
		started = false
		await ally.missed_effect(ally.get_main_target_battler().global_position)
		finished.emit()
