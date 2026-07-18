class_name Enemy extends CharacterBody2D

@onready var hurt_sound: AudioStreamPlayer = %HurtSound
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var random_walker: RandomWalker = %RandomWalker
@onready var collision_shape_2d: CollisionShape2D = %CollisionShape2D
@onready var thought_bubble: Sprite2D = %ThoughtBubble
@onready var player_detection_shape: CollisionShape2D = %PlayerDetectionShape

@export var battle_data: BattleData
@export var chasing_speed := 30

var player: Player

enum States {
	WANDERING,
	CHASING,
	DONE,
}
var state := States.WANDERING

func _ready() -> void:
	var index = battle_data.overworld_enemy_index
	animated_sprite_2d.sprite_frames = (
		battle_data.enemies_data_grid[index.x].
		elements[index.y].sprite_frames
	)

func die() -> void:
	random_walker.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	animated_sprite_2d.stop()
	collision_shape_2d.set_deferred("disabled", true)
	for i in range(6):
		animation_player.play("hurt")
		await animation_player.animation_finished
	queue_free()

func _physics_process(delta: float) -> void:
	if state == States.WANDERING:
		random_walker.set_physics_process(true)
	elif state == States.CHASING:
		random_walker.set_physics_process(false)
		var dir := global_position.direction_to(player.global_position)
		velocity = dir * chasing_speed
		random_walker.update_animation(dir.round())
		move_and_slide()

func _on_player_detection_area_body_entered(body: Node2D) -> void:
	if body is Player:
		player = body
		state = States.CHASING
		thought_bubble.show()

func _on_player_detection_area_body_exited(body: Node2D) -> void:
	if body is Player:
		player = null
		state = States.WANDERING
		thought_bubble.hide()

func done() -> void:
	player_detection_shape.disabled = true
	state = States.DONE
