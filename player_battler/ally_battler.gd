class_name AllyBattler extends Battler

signal finished_deciding_action

@onready var ui: CanvasLayer = $UI
@onready var attack_button: Button = %AttackButton
@onready var skill_animation: AnimatedSprite2D = %SkillAnimation
@onready var experience_bar: ProgressBar = %ExperienceBar
@onready var level_up_manager: LevelUpManager = %LevelUpManager
@onready var magic_bar: ProgressBar = %MagicBar
@onready var buttons: HBoxContainer = %Buttons
@onready var skills_menu: PanelContainer = %SkillsMenu
@onready var skills_container: GridContainer = %SkillsContainer
@onready var skills_button: Button = %SkillsButton
@onready var attack_animation_player: AnimationPlayer = %AttackAnimationPlayer

var _is_attacking := false
var _skill_to_perform: Skill
var _max_magic_points: int = 25
var _EXP_to_next_level: int = 100
var _skills: Array[Skill]
var _magic_points: int
var _EXP: int = 0
var _level: int = 1

func set_up_skills(skills: Array[Skill]) -> void:
	for skill: Skill in skills:
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
			skills_menu.hide()
			ui.hide()
			finished_deciding_action.emit()
		)
	skills_container.add_child(Control.new())
	var back_button := Button.new()
	back_button.text = "return"
	back_button.pressed.connect(func():
		skills_menu.hide()
		buttons.show()
		skills_button.grab_focus()
	)
	skills_container.add_child(back_button)

func _ready() -> void:
	super._ready()
	ui.hide()
	$AttackBar.hide()
	experience_bar.hide()
	skills_menu.hide()
	animated_sprite_2d.play("idle")
	experience_bar.max_value = _EXP_to_next_level
	experience_bar.value = _EXP
	magic_bar.max_value = _max_magic_points
	set_magic_points(_magic_points)
	set_up_skills(_skills)

func decide_action() -> void:
	buttons.show()
	ui.show()
	attack_button.grab_focus()

func perform_action() -> void:
	hide_stat_bars()
	if _action_name == "attack":
		Global.display_text.emit("Ninja Attacked the enemy")
		await Global.textbox_closed
		var final_pos := enemy().global_position - Vector2(25, 0)
		var tween := create_tween().set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "global_position", final_pos, 0.5)
		await tween.finished
		$AttackBar.show()
		_is_attacking = true
		attack_animation_player.speed_scale = randf_range(0.5, 1.25)
		if randf() < 0.5:
			attack_animation_player.play_backwards("attack")
		else:
			attack_animation_player.play("attack")
	elif _action_name == "skill":
		if _skill_to_perform is HealingSkill:
			perform_skill_action(self)
		elif _skill_to_perform is OffensiveSkill:
			perform_skill_action(enemy())
		else:
			assert(false, "no match")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and _is_attacking:
		_is_attacking = false
		animated_sprite_2d.play("attack")
		%Sword.show()
		attack_animation_player.stop(true)
		var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE)
		tween.tween_property(%AttackSlider, "scale", Vector2.ONE*1.5, 0.1)
		tween.tween_property(%AttackSlider, "scale", Vector2.ONE, 0.25)
		await tween.finished
		
		var distance_to_center: int = round(abs(%AttackSlider.position.x - 50))
		var multiplier: float = (50.0 - distance_to_center) / 50.0
		var damage: int = round(_strength * multiplier)
		await enemy().take_damage(damage)
		
		$AttackBar.hide()
		animated_sprite_2d.play("idle")
		%Sword.hide()
		tween = create_tween().set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "global_position", _starting_pos, 0.5)
		await tween.finished
		show_stat_bars()
		finished_performing_action.emit()

func _on_attack_button_pressed() -> void:
	_action_name = "attack"
	_action_text = "Green Ninja slashed the enemy !"
	ui.hide()
	finished_deciding_action.emit()

func enemy() -> EnemyBattler:
	return get_tree().get_first_node_in_group("enemy battler")

func _on_attack_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack":
		_is_attacking = false
		$AttackBar.hide()
		await missed_effect(enemy().global_position)
		var tween = create_tween().set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "global_position", _starting_pos, 0.5)
		await tween.finished
		show_stat_bars()
		finished_performing_action.emit()

func _on_skills_button_pressed() -> void:
	if _magic_points <= 0 or _skills.is_empty():
		%ErrorSound.play()
		return
	_action_name = "skill"
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
			var old_value = _get(key)
			_set(key, old_value + value)
			if key == "max_health":
				_set("_health", _health+value)
		
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

func perform_skill_action(target: Battler) -> void:
	Global.display_text.emit(_skill_to_perform.battle_text)
	await Global.textbox_closed
	var qte: QuickTimeEvent = _skill_to_perform.quick_time_event.instantiate()
	add_child(qte)
	qte.global_position = target.global_position
	target.hide_stat_bars()
	qte.start()
	qte.finished.connect(func(success: bool):
		if success:
			skill_animation.sprite_frames = _skill_to_perform.animation
			skill_animation.global_position = target.global_position
			skill_animation.show()
			skill_animation.play("default")
			%SkillSound.play()
			await skill_animation.animation_finished
			skill_animation.hide()
			target.show_stat_bars()
			if _skill_to_perform is OffensiveSkill:
				await enemy().take_damage(_strength + _skill_to_perform.strength)
			elif _skill_to_perform is HealingSkill:
				await self.heal(_skill_to_perform.heal_amount)
			await get_tree().create_timer(0.1).timeout
			show_stat_bars()
			set_magic_points(_magic_points - _skill_to_perform.magic_points_cost)
		else:
			await missed_effect(target.global_position)
		show_stat_bars()
		finished_performing_action.emit()
		)

func show_stat_bars() -> void:
	super.show_stat_bars()
	magic_bar.show()

func hide_stat_bars() -> void:
	super.hide_stat_bars()
	magic_bar.hide()
