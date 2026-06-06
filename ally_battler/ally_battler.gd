class_name AllyBattler extends Battler

@onready var ui: CanvasLayer = $UI
@onready var skill_animation: AnimatedSprite2D = %SkillAnimation
@onready var experience_bar: ProgressBar = %ExperienceBar
@onready var level_up_manager: LevelUpManager = %LevelUpManager
@onready var magic_bar: ProgressBar = %MagicBar
@onready var buttons: HBoxContainer = %Buttons
@onready var skills_menu: PanelContainer = %SkillsMenu
@onready var skills_container: GridContainer = %SkillsContainer
@onready var skills_button: Button = %SkillsButton
@onready var sword: Sprite2D = %Sword

enum SelectionType {SINGLE_ENEMY, ALL_ENEMIES, ALL_ALLIES, SINGLE_LIVING_ALLY, SINGLE_DEAD_ALLY}
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
var _max_magic_points: int = 25
var _EXP_to_next_level: int = 100
var _skills: Array[Skill]
var _magic_points: int
var _EXP: int = 0
var _level: int = 1

var _selection_index := 0
var _skill_to_perform: Skill
var _dead_allies: Array[AllyBattler]
var skill_selection_area: SkillSelectionArea
var _selection_type: SelectionType
var targets: Array[Battler] = []

func _ready() -> void:
	super._ready()
	ui.hide()
	experience_bar.hide()
	skills_menu.hide()
	animated_sprite_2d.play("idle right")
	experience_bar.max_value = _EXP_to_next_level
	experience_bar.value = _EXP
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
			target.play_selection_animation()
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
	
	assert(false, "unhandled case")
	# Dead code:
	return null

func perform_action() -> void:
	await get_tree().create_timer(0.1).timeout
	hide_stat_bars()
	_starting_pos = self.global_position
	if action_to_perform == ActionType.SKILL:
		Global.display_text.emit(_skill_to_perform.battle_text)
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

func _input(event: InputEvent) -> void:
	if _is_selecting:
		if event.is_action_pressed("move down") or event.is_action_pressed("move right"):
			get_main_target_battler().stop_selection_animation()
			_selection_index += 1
			get_main_target_battler().play_selection_animation()
		elif event.is_action_pressed("move up") or event.is_action_pressed("move left"):
			get_main_target_battler().stop_selection_animation()
			_selection_index -= 1
			get_main_target_battler().play_selection_animation()
		elif event.is_action_pressed("interact"):
			get_main_target_battler().stop_selection_animation()
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
	experience_bar.show()
	_EXP += amount
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(experience_bar, "value", _EXP, 1.0)
	await tween.finished
	# Check if leveled up:
	if _EXP >= _EXP_to_next_level:
		_level += 1
		%LevelUpSound.play()
		var new_EXP := _EXP - _EXP_to_next_level
		_EXP = new_EXP
		@warning_ignore("narrowing_conversion")
		_EXP_to_next_level *= 1.25
		Global.display_text.emit("Ninja reached level %d" % _level)
		await Global.textbox_closed
		var upgrades := level_up_manager.upgrades[_level]
		for key: String in upgrades.stats:
			var value: int = upgrades.stats[key]
			Global.display_text.emit(
				"%s increased by %d" % [key.replace('_',' '), value]
			)
			await Global.textbox_closed
			var old_value = get("_"+key)
			set(key, old_value + value)
			if key == "max_health":
				set("_health", _health+value)
		
		for skill: Skill in upgrades.new_skills:
			_skills.append(skill)
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
	var allies := get_tree().get_nodes_in_group("player battler")
	for ally in allies:
		if ally is AllyBattler:
			if not ally.is_alive:
				_dead_allies.append(ally)

func die() -> void:
	super.die()
	self.modulate.a = 0.5
