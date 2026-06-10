extends QuickTimeEvent

@onready var progress_bar: ProgressBar = %ProgressBar
@onready var instructions_label: RichTextLabel = %InstructionsLabel
var actions: PackedStringArray = ["move up", "move right", "move down", "move left"]
var i := 0

func start(ally: AllyBattler) -> void:
	await ally.move_to(ally.get_main_target_battler().global_position - Vector2(25,0))
	super.start(ally)

func _process(_delta: float) -> void:
	if not started:
		return
	if Input.is_action_pressed(actions[i % len(actions)]):
		i += 1
		progress_bar.value = i
	if progress_bar.value == progress_bar.max_value:
		started = false
		self.hide()
		const ANIM_NAMES = ["up", "right", "down", "left"]
		for i in range(8):
			ally.animated_sprite_2d.play("idle %s" % ANIM_NAMES[i % ANIM_NAMES.size()])
			await get_tree().create_timer(0.1).timeout
		ally.animated_sprite_2d.play("idle right")
		for enemy in ally.targets:
			enemy.take_damage(ally._strength, 1.2)
		await get_tree().create_timer(0.1).timeout
		await ally.move_to(ally_starting_pos)
		finished.emit()
