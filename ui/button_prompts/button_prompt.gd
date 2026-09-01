class_name ButtonPrompt extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D

@export var keyboard_sprite_frames: SpriteFrames
@export var nintendo_sprite_frames: SpriteFrames
@export var playstation_sprite_frames: SpriteFrames
@export var xbox_sprite_frames: SpriteFrames

@onready var sprite_frames: Dictionary[MyInput.InputMode, SpriteFrames] = {
	MyInput.InputMode.KEYBOARD : keyboard_sprite_frames,
	MyInput.InputMode.PLAYSTATION : playstation_sprite_frames,
	MyInput.InputMode.NINTENDO : nintendo_sprite_frames,
	MyInput.InputMode.XBOX : xbox_sprite_frames
}

func _ready() -> void:
	MyInput.input_mode_changed.connect(_on_input_mode_changed)
	_on_input_mode_changed(MyInput.current_input_mode)

func _on_input_mode_changed(new_mode: MyInput.InputMode) -> void:
	animated_sprite_2d.sprite_frames = sprite_frames[new_mode]
	animated_sprite_2d.play()

func get_current_icon() -> Texture:
	return (
		sprite_frames[MyInput.current_input_mode]
		.get_frame_texture("default", 0)
	)
