class_name AllyBattler extends Battler

@onready var ui: CanvasLayer = $UI
@onready var skill_animation: AnimatedSprite2D = %SkillAnimation
@onready var experience_bar: ProgressBar = %ExperienceBar
@onready var magic_bar: ProgressBar = %MagicBar
@onready var buttons: HBoxContainer = %Buttons
@onready var skills_menu: PanelContainer = %SkillsMenu
@onready var skills_container: GridContainer = %SkillsContainer
@onready var skills_button: Button = %SkillsButton
@onready var sword: Sprite2D = %Sword
@onready var error_sound: AudioStreamPlayer = %ErrorSound
@onready var swap_button: Button = %SwapButton

static var number_of_swaps_left := 1

enum SelectionType {
	SINGLE_ENEMY,
	ALL_ENEMIES,
	ALL_ALLIES,
	SINGLE_LIVING_ALLY,
	SINGLE_DEAD_ALLY,
	SINGLE_LIVING_ALLY_NOT_ME,
}
const NO_SELECTION: Array[SelectionType] = [
	SelectionType.ALL_ENEMIES, SelectionType.ALL_ALLIES
]
const ALIVE_ALLY_SELECTION: Array[SelectionType] = [
	SelectionType.ALL_ALLIES, SelectionType.SINGLE_LIVING_ALLY
]
const ENEMY_SELECTION: Array[SelectionType] = [
	SelectionType.ALL_ENEMIES, SelectionType.SINGLE_ENEMY
]

# flags:
var _is_selecting := false

# stats:
var _data: AllyBattlerData
var _max_magic_points: int = 25
var _skills: Array[Skill]
var _magic_points: int

var _selection_index := 0
var _skill_to_perform: Skill
var _dead_allies: Array[AllyBattler]
var _living_allies_not_me: Array[AllyBattler]
var skill_selection_area: SkillSelectionArea
var _selection_type: SelectionType
var targets: Array[Battler] = []

func _ready() -> void:
	super._ready()
	ui.hide()
	experience_bar.hide()
	skills_menu.hide()
	animated_sprite_2d.play("idle right")
	experience_bar.max_value = _data.EXP_to_next_level
	experience_bar.value = _data.EXP
	magic_bar.max_value = _max_magic_points
	set_magic_points(_max_magic_points)
	
	# Set up skills:
	for skill: Skill in _skills:
		var button := Button.new()
		button.text = skill.name
		skills_container.add_child(button)
		var label := Label.new()
		label.text = "%d MP" % skill.magic_points_cost
		skills_container.add_child(label)
		button.pressed.connect(func():
			if _magic_points < skill.magic_points_cost:
				%ErrorSound.play()
				return
			set_magic_points(_magic_points - skill.magic_points_cost)
			_skill_to_perform = skill
			if skill.selection_type in NO_SELECTION:
				skills_menu.hide()
				ui.hide()
				perform_action()
				return
			_is_selecting = true
			_selection_type = skill.selection_type
			skills_menu.hide()
			ui.hide()
			_selection_index = 0
			var target := get_main_target_battler()
			Global.set_cursor_visible.emit(true)
			Global.move_cursor_to.emit(target.global_position)
			if skill.selection_area:
				var area: SkillSelectionArea = skill.selection_area.instantiate()
				add_child(area)
				skill_selection_area = area
				skill_selection_area.highlight_target(self, target)
		)
	
	# Back button for skill menu:
	skills_container.add_child(Control.new())
	var back_button := Button.new()
	back_button.text = "return"
	back_button.pressed.connect(func():
		skills_menu.hide()
		buttons.show()
		skills_button.grab_focus()
	)
	skills_container.add_child(back_button)

func play_turn() -> void:
	update_battlers_arrays()
	Global.set_cursor_visible.emit(true)
	Global.move_cursor_to.emit(self.global_position)
	buttons.show()
	ui.show()
	skills_button.grab_focus()

func get_main_target_battler() -> Battler:
	match _selection_type:
		SelectionType.SINGLE_ENEMY:
			return _enemies[_selection_index % _enemies.size()]
		SelectionType.SINGLE_LIVING_ALLY:
			return _living_allies[_selection_index % _living_allies.size()]
		SelectionType.SINGLE_DEAD_ALLY:
			return _dead_allies[_selection_index % _dead_allies.size()]
		SelectionType.SINGLE_LIVING_ALLY_NOT_ME:
			return _living_allies_not_me[_selection_index % _living_allies_not_me.size()]
	
	assert(false, "unhandled case")
	# Dead code:
	return null

func perform_action() -> void:
	await get_tree().create_timer(0.1).timeout
	hide_stat_bars()
	_starting_pos = self.global_position
	if action_to_perform == ActionType.SKILL:
		Global.display_text.emit(_skill_to_perform.battle_text % battler_name)
		await Global.textbox_closed
		var qte: QuickTimeEvent
		qte = _skill_to_perform.quick_time_event.instantiate()
		add_child(qte)
		qte.start(self)
		qte.finished.connect(func():
			qte.queue_free()
			show_stat_bars()
			finished_turn.emit()
		)
	if action_to_perform == ActionType.SWAP:
		var other := get_main_target_battler()
		AllyBattler.number_of_swaps_left -= 1
		Global.display_text.emit("%s swapped places with %s" % [battler_name, other.battler_name])
		await Global.textbox_closed
		self.move_to(other.global_position)
		await other.move_to(_starting_pos)
		show_stat_bars()
		play_turn()

func _input(event: InputEvent) -> void:
	if not _is_selecting:
		return
	
	if event.is_action_pressed("move down") or event.is_action_pressed("move right"):
		_selection_index += 1
		Global.move_cursor_to.emit(get_main_target_battler().global_position)
	elif event.is_action_pressed("move up") or event.is_action_pressed("move left"):
		_selection_index -= 1
		Global.move_cursor_to.emit(get_main_target_battler().global_position)
	elif event.is_action_pressed("interact"):
		Global.set_cursor_visible.emit(false)
		_is_selecting = false
		if skill_selection_area:
			targets = skill_selection_area.battlers.duplicate()
			skill_selection_area.queue_free()
		ui.hide()
		perform_action()
	if skill_selection_area:
		skill_selection_area.highlight_target(self, get_main_target_battler())

func _on_skills_button_pressed() -> void:
	if _magic_points <= 0 or _skills.is_empty():
		%ErrorSound.play()
		return
	action_to_perform = ActionType.SKILL
	buttons.hide()
	skills_menu.show()
	(skills_container.get_child(0) as Control).grab_focus()

func increase_exp(amount: int) -> void:
	# We update stats first:
	_data.health =_health
	_data.magic_points =_magic_points
	_data.skills =_skills
	
	experience_bar.show()
	_data.EXP += amount
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(experience_bar, "value", _data.EXP, 1.0)
	await tween.finished
	# Check if leveled up:
	if _data.EXP >= _data.EXP_to_next_level:
		_data.level += 1
		%LevelUpSound.play()
		var new_EXP: int = _data.EXP - _data.EXP_to_next_level
		_data.EXP = new_EXP
		@warning_ignore("narrowing_conversion")
		_data.EXP_to_next_level *= 1.25
		Global.display_text.emit("Ninja reached level %d" % _data.level)
		await Global.textbox_closed
		# Check if reached max level:
		if _data.level-1 > len(_data.level_ups):
			return
		var level_up := _data.level_ups[_data.level-2]
		for stat: LevelUp.Stat in level_up.stat_increases.keys():
			var increase_amount: int = level_up.stat_increases[stat]
			var stat_string: String = LevelUp.Stat.keys()[stat]
			stat_string = stat_string.to_lower()
			Global.display_text.emit(
				"%s increased by %d" % [stat_string.replace('_',' '), increase_amount]
			)
			await Global.textbox_closed
			var original_value = _data.get(stat_string)
			_data.set(stat_string, original_value + increase_amount)
		for skill: Skill in level_up.skills:
			_data.skills.append(skill)
			Global.display_text.emit("New Skill Unlocked: %s" % skill.name) 
			await Global.textbox_closed

func set_magic_points(new_val: int) -> void:
	_magic_points = new_val
	magic_bar.value = new_val

func missed_effect(pos: Vector2) -> void:
	const MISS_LABEL = preload("uid://cqw5qj1ygekwl")
	var label: MissLabel = MISS_LABEL.instantiate()
	add_child(label)
	label.global_position = pos
	await label.bouncing_finished
	%ErrorSound.play()
	await %ErrorSound.finished

func show_stat_bars() -> void:
	super.show_stat_bars()
	magic_bar.show()

func hide_stat_bars() -> void:
	super.hide_stat_bars()
	magic_bar.hide()

func update_battlers_arrays() -> void:
	super.update_battlers_arrays()
	_dead_allies = []
	_living_allies_not_me = []
	var allies := get_tree().get_nodes_in_group("player battler")
	for ally in allies:
		if ally is AllyBattler:
			if not ally.is_alive:
				_dead_allies.append(ally)
			else:
				if ally != self:
					_living_allies_not_me.append(ally)

func die() -> void:
	super.die()
	self.modulate.a = 0.5


func _on_swap_button_pressed() -> void:
	if AllyBattler.number_of_swaps_left == 0:
		ui.hide()
		error_sound.play()
		Global.display_text.emit("Can't swap places anymore this turn")
		await Global.textbox_closed
		ui.show()
		swap_button.grab_focus()
		return
	if len(_living_allies_not_me) == 0:
		ui.hide()
		error_sound.play()
		Global.display_text.emit("Nobody left alive to swap with")
		await Global.textbox_closed
		ui.show()
		swap_button.grab_focus()
		return
	_is_selecting = true
	_selection_type = SelectionType.SINGLE_LIVING_ALLY_NOT_ME
	action_to_perform = ActionType.SWAP
	skills_menu.hide()
	ui.hide()
	_selection_index = 0
	var target := get_main_target_battler()
	Global.set_cursor_visible.emit(true)
	Global.move_cursor_to.emit(target.global_position)
