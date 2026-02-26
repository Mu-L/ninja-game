@abstract
class_name Battler extends Node2D

signal finished_performing_action

@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var health_bar: ProgressBar = %HealthBar
@onready var damage_label: Label = %DamageLabel
@onready var hp_label: Label = $HPLabel

var data: BattlerData: set = set_data
var action_name: String
var action_text: String
var starting_pos: Vector2

func set_data(new_val: BattlerData) -> void:
	data = new_val
	animated_sprite_2d.sprite_frames = data.sprite_frames
	animated_sprite_2d.play("idle")
	set_health(data.health)

func _ready() -> void:
	starting_pos = self.global_position
	damage_label.hide()

func _process(delta: float) -> void:
	if not hp_label:
		return
	hp_label.text = "%d" % data.health

@abstract
func decide_action() -> void

@abstract
func perform_action() -> void

@abstract
func take_damage(amount: int) -> void

func set_health(new_val: int) -> void:
	data.health = new_val
	health_bar.value = new_val
