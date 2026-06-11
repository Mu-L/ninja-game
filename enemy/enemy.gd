class_name Enemy extends CharacterBody2D

@onready var hurt_sound: AudioStreamPlayer = %HurtSound
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var random_walker: RandomWalker = %RandomWalker
@onready var collision_shape_2d: CollisionShape2D = %CollisionShape2D

@export var battle_data: BattleData

func _ready() -> void:
	animated_sprite_2d.sprite_frames = (
		battle_data.enemy_positions
		.values()[battle_data.overworld_enemy_index]
		.sprite_frames
	)

func die() -> void:
	random_walker.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	animated_sprite_2d.stop()
	collision_shape_2d.set_deferred("disabled", true)
	for i in range(6):
		animation_player.play("hurt")
		await animation_player.animation_finished
	queue_free()
