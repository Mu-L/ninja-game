class_name Follower extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var label: Label = $Label

var player: Player
var data: AllyBattlerData
var movement_speed: int
var last_dir := "up"
var step_delay: int

static func create(data:AllyBattlerData, player:Player, step_delay, movement_speed:int=100) -> Follower:
	const FOLLOWER := preload("uid://c2t5payqh47nf")
	var follower: Follower = FOLLOWER.instantiate()
	follower.movement_speed = movement_speed
	follower.data = data
	follower.player = player
	follower.step_delay = step_delay
	return follower

func _ready() -> void:
	animated_sprite_2d.sprite_frames = data.sprite_frames
	global_position = player.global_position

func _process(delta: float) -> void:
	
	label.text = str(step_delay % player.position_history.size())
	
	if player.velocity == Vector2.ZERO:
		animated_sprite_2d.play("idle %s" % last_dir)
		return
	var next_pos := player.position_history[step_delay % player.position_history.size()]
	step_delay += 1
	var dir := global_position.direction_to(next_pos)
	global_position = next_pos
	animated_sprite_2d.play("walk %s" % last_dir)
	
	var rounded: Vector2 = round(dir)
	if rounded.x > 0:
		last_dir = "right"
	if rounded.x < 0:
		last_dir = "left"
	if rounded.y > 0:
		last_dir = "down"
	if rounded.y < 0:
		last_dir = "up"
