extends QuickTimeEvent

@onready var progress_bar: ProgressBar = %ProgressBar
var actions: PackedStringArray = ["move up", "move right", "move down", "move left"]
var i := 0
var ally: AllyBattler

func start(ally: AllyBattler) -> void:
	await ally.move_to(ally.get_target_battler().global_position - Vector2(25,0))
	started = true
	self.ally = ally

func _process(_delta: float) -> void:
	if not started:
		return
	if Input.is_action_pressed(actions[i % len(actions)]):
		i += 1
		progress_bar.value = i
	if progress_bar.value == progress_bar.max_value:
		started = false
		progress_bar.hide()
		const ANIM_NAMES = ["up", "right", "down", "left"]
		for i in range(8):
			ally.animated_sprite_2d.play("idle %s" % ANIM_NAMES[i % ANIM_NAMES.size()])
			await get_tree().create_timer(0.1).timeout
		ally.animated_sprite_2d.play("idle right")
		await ally.move_to(ally._starting_pos)
		var result: Dictionary[Battler,int] = {}
		for battler in ally.targets:
			result[battler] = 2
		finished.emit(result)
