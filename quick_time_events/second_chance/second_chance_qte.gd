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
	(target as AllyBattler).played_turn = false
	target.animated_sprite_2d.modulate.a = 1.0
	finished.emit()
