class_name Enemy extends CharacterBody2D

@onready var hurt_sound: AudioStreamPlayer = %HurtSound
@onready var animation_player: AnimationPlayer = %AnimationPlayer

@export var battle_data: BattlerData
@export var health: int = 3
@export var strength: int = 1

func die() -> void:
	set_physics_process(false)
	for i in range(6):
		animation_player.play("hurt")
		await animation_player.animation_finished
	queue_free()
