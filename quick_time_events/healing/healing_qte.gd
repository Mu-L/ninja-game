extends QuickTimeEvent

@export var qte_duration: float = 5.0

@onready var health_receptacle: Receptacle = %HealthReceptacle
@onready var timer: Timer = %Timer
@onready var time_left_label: Label = %TimeLeftLabel
@onready var healing_sound: AudioStreamPlayer = %HealingSound
@onready var instruction_label: RichTextLabel = %InstructionLabel
@onready var healing_effect: AnimatedSprite2D = %HealingEffect
@onready var canvas_layer: CanvasLayer = %CanvasLayer

var healing_amount := 0

func start(ally: AllyBattler) -> void:
	super.start(ally)
	started = false
	instruction_label.text = Util.BBCode_wave(
		instruction_label.text % (target as AllyBattler).get_colored_name()
	)
	await health_receptacle.update(
		float(target._health) / target._max_health
	)
	started = true
	timer.start(qte_duration)

func _process(_delta: float) -> void:
	if not started:
		return
	
	time_left_label.text = "%.2f" % timer.time_left
	
	if Input.is_action_just_pressed("interact"):
		healing_amount += 3
		health_receptacle.update(
			float(target._health + healing_amount) / target._max_health
		)
	
	var x := health_receptacle.is_full()
	var y := timer.is_stopped()
	if x or y:
		canvas_layer.hide()
		started = false
		healing_sound.play()
		healing_effect.show()
		healing_effect.global_position = target.global_position
		ally.get_main_target_battler().heal(healing_amount)
		healing_effect.play("default")
		await healing_effect.animation_finished
		healing_effect.hide()
		await get_tree().create_timer(0.1).timeout
		finished.emit()
