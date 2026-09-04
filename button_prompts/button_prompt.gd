class_name ButtonPrompt extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D

@export var button_icon_data: ButtonIconData

func _ready() -> void:
	MyInput.input_mode_changed.connect(_on_input_mode_changed)
	_on_input_mode_changed()

func _on_input_mode_changed() -> void:
	animated_sprite_2d.sprite_frames = (
		MyInput.get_sprite_frames(button_icon_data)
	)
	animated_sprite_2d.play()
