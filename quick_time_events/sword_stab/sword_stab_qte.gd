extends QuickTimeEvent

@onready var attack_bar: Control = %AttackBar
@onready var attack_animation_player: AnimationPlayer = %AttackAnimationPlayer
@onready var attack_slider: Sprite2D = %AttackSlider

var _is_attacking := false

func start(ally: AllyBattler) -> void:
	super.start(ally)
	attack_slider.position = Vector2.ZERO
	var enemy := ally.get_main_target_battler()
	await ally.move_to(enemy.global_position - Vector2(25, 0))
	attack_bar.show()
	_is_attacking = true
	attack_animation_player.play("attack")

func _on_attack_animation_player_animation_finished(_anim_name: StringName) -> void:
	_is_attacking = false
	attack_bar.hide()
	await ally.missed_effect(ally.get_main_target_battler().global_position)
	await ally.move_to(ally_starting_pos)
	finished.emit()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and _is_attacking:
		_is_attacking = false
		ally.animated_sprite_2d.play("attack right")
		ally.sword.show()
		attack_animation_player.stop(true)
		var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE)
		tween.tween_property(attack_slider, "scale", Vector2.ONE*1.5, 0.1)
		tween.tween_property(attack_slider, "scale", Vector2.ONE, 0.25)
		await tween.finished
		
		var distance_to_center: int = round(abs(attack_slider.position.x - 50))
		var multiplier: float = (50.0 - distance_to_center) / 50.0
		multiplier *= 2
		await ally.get_main_target_battler().take_damage(ally._strength, multiplier)
		
		attack_bar.hide()
		ally.animated_sprite_2d.play("idle right")
		ally.sword.hide()
		await ally.move_to(ally_starting_pos)
		finished.emit()
