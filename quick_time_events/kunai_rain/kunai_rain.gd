extends QuickTimeEvent

@onready var attack_bar: Control = %AttackBar
@onready var attack_animation_player: AnimationPlayer = %AttackAnimationPlayer
@onready var attack_slider: Sprite2D = %AttackSlider
@onready var smoke_effect: AnimatedSprite2D = %SmokeEffect
@onready var smoke_sound: AudioStreamPlayer = %SmokeSound
@onready var kunai_rain: AnimatedSprite2D = %KunaiRain
@onready var kunai_sound: AudioStreamPlayer = %KunaiSound
@onready var accept_sound: AudioStreamPlayer = %AcceptSound

var _is_attacking := false

func start(ally: AllyBattler) -> void:
	super.start(ally)
	attack_bar.hide()
	smoke_effect.global_position = ally.global_position
	smoke_effect.show()
	smoke_sound.play()
	smoke_effect.play("default")
	ally.animated_sprite_2d.hide()
	await smoke_effect.animation_finished
	smoke_effect.hide()
	
	attack_slider.position = Vector2.ZERO
	attack_bar.show()
	_is_attacking = true
	attack_animation_player.play("attack")

func _on_attack_animation_player_animation_finished(_anim_name: StringName) -> void:
	_is_attacking = false
	attack_bar.hide()
	await ally.missed_effect(ally.get_main_target_battler().global_position)
	await show_ally()
	finished.emit()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and _is_attacking:
		accept_sound.play()
		_is_attacking = false
		attack_animation_player.stop(true)
		var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE)
		tween.tween_property(attack_slider, "scale", Vector2.ONE*1.5, 0.1)
		tween.tween_property(attack_slider, "scale", Vector2.ONE, 0.25)
		await tween.finished
		
		kunai_rain.show()
		var enemy := ally.get_main_target_battler()
		kunai_rain.global_position = enemy.global_position
		kunai_sound.play()
		kunai_rain.play("default")
		await kunai_rain.animation_finished
		kunai_rain.hide()
		
		var distance_to_center: int = round(abs(attack_slider.position.x - 50))
		var multiplier: float = (50.0 - distance_to_center) / 50.0
		multiplier *= 2
		await enemy.take_damage(ally._strength, multiplier)
		
		attack_bar.hide()
		await show_ally()
		finished.emit()

func show_ally() -> void:
	smoke_effect.show()
	smoke_sound.play()
	smoke_effect.play("default")
	await smoke_effect.animation_finished
	ally.animated_sprite_2d.show()
