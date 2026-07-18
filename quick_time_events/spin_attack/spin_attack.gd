extends QuickTimeEvent

@onready var progress_bar: TextureProgressBar = %ProgressBar
@onready var canvas_layer: CanvasLayer = %CanvasLayer
@onready var slash_effect: AnimatedSprite2D = %SlashEffect
@onready var slash_sound: AudioStreamPlayer = %SlashSound
@onready var instructions_label: RichTextLabel = %InstructionsLabel
@onready var timer: Timer = %Timer
@onready var timer_label: Label = %TimerLabel

var actions: PackedStringArray = ["move right", "move left"]
var i := 0

func _ready() -> void:
	instructions_label.text = Util.BBCode_wave(instructions_label.text)

func start(ally: AllyBattler) -> void:
	await ally.move_to(ally.get_main_target_battler().global_position - Vector2(25,0))
	super.start(ally)
	timer.start()

func _process(_delta: float) -> void:
	if not started:
		return
	timer_label.text = "%.2f" % timer.time_left
	if Input.is_action_just_pressed(actions[i % len(actions)]):
		i += 3
		var tween := create_tween()
		tween.tween_property(progress_bar, "value", i, 0.15)
	if progress_bar.value == progress_bar.max_value:
		timer.stop()
		started = false
		canvas_layer.hide()
		slash_effect.show()
		slash_effect.play("default")
		slash_sound.play()
		#await slash_effect.animation_finished
		const ANIM_NAMES = ["up", "right", "down", "left"]
		for i in range(4):
			ally.animated_sprite_2d.play("idle %s" % ANIM_NAMES[i % ANIM_NAMES.size()])
			await get_tree().create_timer(0.1).timeout
		slash_effect.hide()
		ally.animated_sprite_2d.play("idle right")
		for enemy in ally.targets:
			enemy.take_damage(ally._strength, 1.2)
		await get_tree().create_timer(0.1).timeout
		await ally.move_to(ally_starting_pos)
		finished.emit()

func _on_timer_timeout() -> void:
	started = false
	target.show_stat_bars()
	await ally.missed_effect(target.global_position)
	await ally.move_to(ally_starting_pos)
	finished.emit()
