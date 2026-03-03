class_name PlayerBattler extends Battler

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

signal finished_deciding_action

var is_attacking := false
var skill_to_perform: Skill

func _process(_delta: float) -> void:
	hp_label.text = "%d" % data.magic_points

func set_data(new_val: BattlerData) -> void:
	super.set_data(new_val)
	experience_bar.max_value = data.EXP_to_next_level
	experience_bar.value = data.EXP
	magic_bar.max_value = data.max_magic_points
	set_magic_points(data.magic_points)
	set_up_skills(data.skills)

func set_up_skills(skills: Array[Skill]) -> void:
	for skill: Skill in data.skills:
		var button := Button.new()
		button.text = skill.name
		skills_container.add_child(button)
		var label := Label.new()
		label.text = "%d MP" % skill.magic_points_cost
		skills_container.add_child(label)
		button.pressed.connect(func():
			if data.magic_points < skill.magic_points_cost:
				%ErrorSound.play()
				return
			skill_to_perform = skill
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

func decide_action() -> void:
	buttons.show()
	ui.show()
	attack_button.grab_focus()

func perform_action() -> void:
	set_stat_visibility(false)
	if action_name == "attack":
		Global.display_text.emit("Ninja Attacked the enemy")
		await Global.textbox_closed
		var final_pos := enemy().global_position - Vector2(25, 0)
		var tween := create_tween().set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "global_position", final_pos, 0.5)
		await tween.finished
		$AttackBar.show()
		is_attacking = true
		attack_animation_player.speed_scale = randf_range(0.5, 1.25)
		if randf() < 0.5:
			attack_animation_player.play_backwards("attack")
		else:
			attack_animation_player.play("attack")
	elif action_name == "skill":
		if skill_to_perform is HealingSkill:
			perform_skill_action(self)
		elif skill_to_perform is OffensiveSkill:
			perform_skill_action(enemy())
		else:
			assert(false, "no match")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and is_attacking:
		is_attacking = false
		animated_sprite_2d.play("attack")
		%Sword.show()
		attack_animation_player.stop(true)
		var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE)
		tween.tween_property(%AttackSlider, "scale", Vector2.ONE*1.5, 0.1)
		tween.tween_property(%AttackSlider, "scale", Vector2.ONE, 0.25)
		await tween.finished
		
		var distance_to_center: int = round(abs(%AttackSlider.position.x - 50))
		var multiplier: float = (50.0 - distance_to_center) / 50.0
		var damage: int = round(data.strength * multiplier)
		await enemy().take_damage(damage)
		
		$AttackBar.hide()
		animated_sprite_2d.play("idle")
		%Sword.hide()
		tween = create_tween().set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "global_position", starting_pos, 0.5)
		await tween.finished
		set_stat_visibility(true)
		finished_performing_action.emit()

func _on_attack_button_pressed() -> void:
	action_name = "attack"
	action_text = "Green Ninja slashed the enemy !"
	ui.hide()
	finished_deciding_action.emit()

func enemy() -> EnemyBattler:
	return get_tree().get_first_node_in_group("enemy battler")

func take_damage(amount: int) -> void:
	%HurtSound.play()
	%HurtAnimationPlayer.play("hurt")
	set_health(data.health - amount)
	await %HurtAnimationPlayer.animation_finished
	if data.health <= 0:
		queue_free()

func _on_attack_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack":
		is_attacking = false
		$AttackBar.hide()
		await missed_effect(enemy().global_position)
		var tween = create_tween().set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "global_position", starting_pos, 0.5)
		await tween.finished
		set_stat_visibility(true)
		finished_performing_action.emit()

func _on_skills_button_pressed() -> void:
	if data.magic_points <= 0 or data.skills.is_empty():
		%ErrorSound.play()
		return
	action_name = "skill"
	buttons.hide()
	skills_menu.show()
	(skills_container.get_child(0) as Control).grab_focus()

func increase_exp(amount: int) -> void:
	experience_bar.show()
	data.EXP += amount
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(experience_bar, "value", data.EXP, 1.0)
	await tween.finished
	# Check if leveled up:
	if data.EXP >= data.EXP_to_next_level:
		data.level += 1
		%LevelUpSound.play()
		var new_EXP := data.EXP - data.EXP_to_next_level
		data.EXP = new_EXP
		@warning_ignore("narrowing_conversion")
		data.EXP_to_next_level *= 1.25
		Global.display_text.emit("Ninja reached level %d" % data.level)
		await Global.textbox_closed
		var upgrades := level_up_manager.upgrades[data.level]
		for key: String in upgrades.stats:
			var value: int = upgrades.stats[key]
			Global.display_text.emit(
				"%s increased by %d" % [key.replace('_',' '), value]
			)
			await Global.textbox_closed
			var old_value = data.get(key)
			data.set(key, old_value + value)
			if key == "max_health":
				data.set("health", data.health+value)
		
		for skill: Skill in upgrades.new_skills:
			data.skills.append(skill)
			Global.display_text.emit("New Skill Unlocked: %s" % skill.name) 
			await Global.textbox_closed

func set_magic_points(new_val: int) -> void:
	data.magic_points = new_val
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
	Global.display_text.emit(skill_to_perform.battle_text)
	await Global.textbox_closed
	var qte: QuickTimeEvent = skill_to_perform.quick_time_event.instantiate()
	add_child(qte)
	qte.global_position = target.global_position
	qte.start()
	qte.finished.connect(func(success: bool):
		if success:
			skill_animation.sprite_frames = skill_to_perform.animation
			skill_animation.global_position = target.global_position
			skill_animation.show()
			skill_animation.play("default")
			%SkillSound.play()
			await skill_animation.animation_finished
			skill_animation.hide()
			if skill_to_perform is OffensiveSkill:
				await enemy().take_damage(data.strength + skill_to_perform.strength)
			elif skill_to_perform is HealingSkill:
				await self.heal(skill_to_perform.heal_amount)
			await get_tree().create_timer(0.1).timeout
			set_stat_visibility(true)
			set_magic_points(data.magic_points - skill_to_perform.magic_points_cost)
		else:
			await missed_effect(target.global_position)
		set_stat_visibility(true)
		finished_performing_action.emit()
		)

func heal(amount: int) -> void:
	set_health(data.health + amount)
	damage_label.show()
	damage_label.text = str(amount)
	%HealSound.play()
	%HurtAnimationPlayer.play("hurt")
	await %HurtAnimationPlayer.animation_finished
	damage_label.hide()

@warning_ignore("shadowed_variable_base_class")
func set_stat_visibility(is_visible: bool) -> void:
	health_bar.visible = is_visible
	magic_bar.visible = is_visible
