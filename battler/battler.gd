@abstract
class_name Battler extends Node2D

@warning_ignore("unused_signal")
signal finished_performing_action

@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var health_bar: ProgressBar = %HealthBar
@onready var number_label: Label = %NumberLabel
@onready var hp_label: Label = $HPLabel

var data: BattlerData: set = set_data
var action_name: String
var action_text: String
var starting_pos: Vector2

func set_data(new_val: BattlerData) -> void:
	data = new_val
	animated_sprite_2d.sprite_frames = data.sprite_frames
	health_bar.max_value = data.max_health
	set_health(data.health)

func _ready() -> void:
	starting_pos = self.global_position
	number_label.hide()

func _process(_delta: float) -> void:
	if not hp_label:
		return
	hp_label.text = "%d" % data.health

@abstract
func decide_action() -> void

@abstract
func perform_action() -> void

func take_damage(amount: int) -> void:
	%HurtSound.play()
	%HurtAnimationPlayer.play("hurt")
	set_health(data.health - amount)
	await bounce_number_label(amount)
	if data.health <= 0:
		queue_free()

func heal(amount: int) -> void:
	set_health(data.health + amount)
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
	data.health = clamp(new_val, 0, data.max_health)
	health_bar.value = new_val
