class_name InteractableComponent extends Area2D

signal interacted

@onready var button_prompt_confirm: Node2D = %ButtonPrompt


var player: Player = null
static var is_interacting: bool = false

func _ready() -> void:
	button_prompt_confirm.hide()

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		button_prompt_confirm.show()
		player = body

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		button_prompt_confirm.hide()
		player = null

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("primary action") and player:
		button_prompt_confirm.hide()
		get_tree().paused = true
		is_interacting = true
		interacted.emit()
