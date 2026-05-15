@abstract
class_name Battler extends Node2D

signal finished_performing_action

@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var health_bar: ProgressBar = %HealthBar
@onready var number_label: Label = %NumberLabel
@onready var hp_label: Label = $HPLabel

@warning_ignore("unused_private_class_variable")
var _action_name: String
@warning_ignore("unused_private_class_variable")
var _action_text: String

# stats:
var _max_health: int = 100
var _strength: int = 25
var _defense: int = 20
var _speed: int = 20
var _health: int

# visuals:
var battler_name: String
var _sprite_frames: SpriteFrames
var _animation_speed: float = 5.0
var _starting_pos: Vector2

# flags:
var _is_valid_instance := false
var is_alive := true

static func create(data: BattlerData) -> Battler:
	var battler: Battler
	if data is AllyBattlerData:
		const ALLY_BATTLER = preload("uid://l44h5nb2ub5t")
		battler = ALLY_BATTLER.instantiate() as AllyBattler
		battler._max_magic_points = data.max_magic_points
		battler._magic_points = data.magic_points
		battler._level = data.level
		battler._EXP = data.EXP
		battler._EXP_to_next_level = data.EXP_to_next_level
		battler._skills = data.skills
	elif data is EnemyBattlerData:
		const ENEMY_BATTLER = preload("uid://b2i8v282cle12")
		battler = ENEMY_BATTLER.instantiate() as EnemyBattler
	else:
		assert(false, "undefined case...")
	battler._is_valid_instance = true
	battler._max_health = data.max_health
	battler._strength = data.strength
	battler._defense = data.defense
	battler._speed = data.speed
	battler._health = data.health
	battler._sprite_frames = data.sprite_frames
	battler._animation_speed = data.animation_speed
	return battler

func _ready() -> void:
	assert(_is_valid_instance, "create a battler using the static create() method")
	number_label.hide()
	animated_sprite_2d.sprite_frames = _sprite_frames
	animated_sprite_2d.speed_scale = _animation_speed
	health_bar.max_value = _max_health
	set_health(_health)

@abstract
func decide_action() -> void

@abstract
func perform_action() -> void

func take_damage(amount: int) -> void:
	%HurtSound.play()
	%HurtAnimationPlayer.play("hurt")
	set_health(_health - amount)
	await bounce_number_label(amount)
	if _health <= 0:
		queue_free()

func heal(amount: int) -> void:
	set_health(_health + amount)
	%HealSound.play()
	%HurtAnimationPlayer.play("hurt")
	await bounce_number_label(amount)

func bounce_number_label(amount: int) -> void:
	number_label.show()
	number_label.text = "%d" % amount
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(number_label, "scale", Vector2.ONE*1.5, 0.1)
	tween.tween_property(number_label, "scale", Vector2.ONE, 0.25)
	await tween.finished
	number_label.hide()

func set_health(new_val: int) -> void:
	_health = clamp(new_val, 0, _max_health)
	health_bar.value = new_val

func show_stat_bars() -> void:
	health_bar.show()

func hide_stat_bars() -> void:
	health_bar.hide()
