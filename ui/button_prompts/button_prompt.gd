class_name ButtonPrompt extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D

@export var keyboard_sprite_frames: SpriteFrames
@export var nintendo_sprite_frames: SpriteFrames
@export var playstation_sprite_frames: SpriteFrames
@export var xbox_sprite_frames: SpriteFrames

func _ready() -> void:
	Global.input_mode_changed.connect(_on_input_mode_changed)
	_on_input_mode_changed(Global.current_input_mode)

func _on_input_mode_changed(new_mode: Global.InputMode) -> void:
	match new_mode:
		Global.InputMode.KEYBOARD:
			animated_sprite_2d.sprite_frames = keyboard_sprite_frames
		Global.InputMode.NINTENDO:
			animated_sprite_2d.sprite_frames = nintendo_sprite_frames
		Global.InputMode.PLAYSTATION:
			animated_sprite_2d.sprite_frames = playstation_sprite_frames
		Global.InputMode.XBOX:
			animated_sprite_2d.sprite_frames = xbox_sprite_frames
	animated_sprite_2d.play()
