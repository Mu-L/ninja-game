extends QuickTimeEvent

@onready var effect: AnimatedSprite2D = %Effect
@onready var sound: AudioStreamPlayer = %Sound

func start(ally: AllyBattler) -> void:
	super.start(ally)
	sound.play()
	target.animation_player.play("hurt")
	effect.global_position = target.global_position
	effect.show()
	effect.play("default")
	await effect.animation_finished
	effect.hide()
	target.is_alive = true
	target.heal(target._max_health/2)
	target.animated_sprite_2d.modulate.a = 1.0
	target.animated_sprite_2d.play("idle right")
	Global.give_extra_turn.emit(target)
	finished.emit()
