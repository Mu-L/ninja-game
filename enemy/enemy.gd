class_name Enemy extends CharacterBody2D

@onready var hurt_sound: AudioStreamPlayer = %HurtSound
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var random_walker: RandomWalker = %RandomWalker
@onready var collision_shape_2d: CollisionShape2D = %CollisionShape2D

@export var battle_data: BattlerData
@export var health: int = 3
@export var strength: int = 1

func die() -> void:
	random_walker.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	animated_sprite_2d.stop()
	collision_shape_2d.set_deferred("disabled", true)
	for i in range(6):
		animation_player.play("hurt")
		await animation_player.animation_finished
	queue_free()
