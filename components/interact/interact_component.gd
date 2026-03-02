class_name InteractableComponent extends Area2D

signal interacted

@onready var animation: AnimatedSprite2D = %animation

var player: Player = null
static var is_interacting: bool = false

func _ready() -> void:
	animation.hide()

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		animation.show()
		animation.play("default")
		player = body

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		animation.hide()
		animation.stop()
		player = null

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and player:
		get_tree().paused = true
		is_interacting = true
		interacted.emit()
