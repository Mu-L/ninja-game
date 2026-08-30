extends ButtonPrompt

@export var switch_left_spriteframes: SpriteFrames
@export var switch_right_spriteframes: SpriteFrames
@export var keyboard_left_spriteframes: SpriteFrames
@export var keyboard_right_spriteframes: SpriteFrames

@onready var animated_sprite_2d_left: AnimatedSprite2D = %AnimatedSprite2DLeft
@onready var animated_sprite_2d_right: AnimatedSprite2D = %AnimatedSprite2DRight


func _on_input_mode_changed(new_mode: Global.InputMode) -> void:
	match new_mode:
		Global.InputMode.PLAYSTATION:
			animated_sprite_2d.sprite_frames = playstation_sprite_frames
		Global.InputMode.XBOX:
			animated_sprite_2d.sprite_frames = xbox_sprite_frames
		Global.InputMode.KEYBOARD:
			animated_sprite_2d_left.sprite_frames = keyboard_left_spriteframes
			animated_sprite_2d_right.sprite_frames = keyboard_right_spriteframes
		Global.InputMode.NINTENDO:
			animated_sprite_2d_left.sprite_frames = switch_left_spriteframes
			animated_sprite_2d_right.sprite_frames = switch_right_spriteframes
	if new_mode in [Global.InputMode.PLAYSTATION, Global.InputMode.XBOX]:
		animated_sprite_2d_left.hide()
		animated_sprite_2d_right.hide()
		animated_sprite_2d.show()
		animated_sprite_2d.play()
	else:
		animated_sprite_2d_left.show()
		animated_sprite_2d_right.show()
		animated_sprite_2d_left.play()
		animated_sprite_2d_right.play()
		animated_sprite_2d.hide()
