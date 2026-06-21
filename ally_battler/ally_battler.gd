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
var played_turn := false

# stats:
var _data: AllyBattlerData
var _max_magic_points: int = 25
var _skills: Array[Skill]
var _magic_points: int

var text_color: Color
var _selection_index := 0
var _enemy_selection_index: Vector2i = Vector2.ZERO
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
			_enemy_selection_index = Vector2.ZERO
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
		SelectionType.SINGLE_LIVING_ALLY:
			return _living_allies[_selection_index % _living_allies.size()]
		SelectionType.SINGLE_DEAD_ALLY:
			return _dead_allies[_selection_index % _dead_allies.size()]
		SelectionType.SINGLE_LIVING_ALLY_NOT_ME:
			return _living_allies_not_me[_selection_index % _living_allies_not_me.size()]
		SelectionType.SINGLE_ENEMY:
			var enemy := _enemies_grid[_enemy_selection_index.x].elements[_enemy_selection_index.y]
			if enemy:
				return enemy
			_enemy_selection_index.x = 0
			while _enemy_selection_index.x < _enemies_grid.size():
				_enemy_selection_index.y = 0
				while _enemy_selection_index.y < _enemies_grid[_enemy_selection_index.x].elements.size():
					enemy = _enemies_grid[_enemy_selection_index.x].elements[_enemy_selection_index.y]
					if enemy:
						return enemy
					_enemy_selection_index.y += 1
				_enemy_selection_index.x += 1
			return enemy
		_:
			assert(false, "%s is unhandled case!" % SelectionType.keys()[_selection_type])
			return null


func perform_action() -> void:
	played_turn = true
	await get_tree().create_timer(0.1).timeout
	hide_stat_bars()
	_starting_pos = self.global_position
	set_magic_points(_magic_points - _skill_to_perform.magic_points_cost)
	Global.display_text.emit(_skill_to_perform.battle_text % Util.BBcode_color(battler_name, text_color))
	await Global.textbox_closed
	var qte: QuickTimeEvent
	qte = _skill_to_perform.quick_time_event.instantiate()
	add_child(qte)
	qte.start(self)
	qte.finished.connect(func():
		qte.queue_free()
		show_stat_bars()
		self.animated_sprite_2d.modulate.a = 0.75
		finished_turn.emit()
	)
	if action_to_perform == ActionType.ROTATE:
		var other := get_main_target_battler()
		Global.display_text.emit("%s swapped places with %s" % [battler_name, other.battler_name])
		await Global.textbox_closed
		self.move_to(other.global_position)
		await other.move_to(_starting_pos)
		show_stat_bars()
		play_turn()

var _input_buffer_timer := 0.0
const _INPUT_DELAY := 0.05
var _buffered_index_offset := Vector2i.ZERO

func _process(delta: float) -> void:
	if not _is_selecting or not Input.is_anything_pressed() or Global.is_cursor_moving:
		_input_buffer_timer = 0.0
		_buffered_index_offset = Vector2i.ZERO
		return
	
	# Cancel selection:
	if Input.is_action_just_pressed("attack"):
		_is_selecting = false
		skills_menu.show()
		ui.show()
		(skills_container.get_child(0) as Control).grab_focus()
		Global.move_cursor_to.emit(self.global_position)
		if skill_selection_area:
			skill_selection_area.queue_free()
	
	if _selection_type == SelectionType.SINGLE_ENEMY:
		var index_offset := Vector2i.ZERO
		if Input.is_action_pressed("move right"):
			index_offset.y = 1
		if Input.is_action_pressed("move left"):
			index_offset.y = -1
		if Input.is_action_pressed("move up"):
			index_offset.x = -1
		if Input.is_action_pressed("move down"):
			index_offset.x = 1
		
		if index_offset.x != 0:
			_buffered_index_offset.x = index_offset.x
		if index_offset.y != 0:
			_buffered_index_offset.y = index_offset.y
		
		_input_buffer_timer += delta
		if _input_buffer_timer >= _INPUT_DELAY:
			_input_buffer_timer = 0.0
			_buffered_index_offset = Vector2i.ZERO
			var enemy: EnemyBattler 
			while enemy == null:
				_enemy_selection_index += index_offset
				_enemy_selection_index %= _enemies_grid.size()
				enemy = _enemies_grid[_enemy_selection_index.x].elements[_enemy_selection_index.y]
			Global.move_cursor_to.emit(enemy.global_position)
	
	elif _selection_type == SelectionType.SINGLE_LIVING_ALLY:
		if Input.is_action_pressed("move right"):
			_selection_index = 0
		if Input.is_action_pressed("move down"):
			_selection_index = 1
		if Input.is_action_pressed("move left"):
			_selection_index = 2
		if Input.is_action_pressed("move up"):
			_selection_index = 3
		Global.move_cursor_to.emit(get_main_target_battler().global_position)
	
	if Input.is_action_pressed("interact"):
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
	animated_sprite_2d.modulate.a = 0.75
	animated_sprite_2d.play("dead")
