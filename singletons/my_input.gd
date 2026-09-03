extends Node

@onready var button_icon_data: Dictionary[String, ButtonIconData] = {
	"[CONFIRM]" : preload("uid://djmypdcxk76p3"),
	"[ATTACK]" : preload("uid://cxx1mamkhfdvv"),
	"[MENU]" : preload("uid://4bsv61q0xkto"),
	"[LEFT]" : preload("uid://kwucpuslu335"),
	"[RIGHT]" : preload("uid://b516xopujv2mv"),
}

signal input_mode_changed

enum InputMode {
	KEYBOARD,
	PLAYSTATION,
	XBOX,
	NINTENDO,
}

var current_input_mode := InputMode.KEYBOARD

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func get_sprite_frames(button_icon_data: ButtonIconData) -> SpriteFrames:
	match current_input_mode:
		InputMode.KEYBOARD:
			return button_icon_data.keyboard_sprite_frames
		InputMode.PLAYSTATION:
			return button_icon_data.playstation_sprite_frames
		InputMode.NINTENDO:
			return button_icon_data.nintendo_sprite_frames
		_:
			return button_icon_data.xbox_sprite_frames

func get_icon(tag: String) -> Texture:
	return get_sprite_frames(button_icon_data[tag]).get_frame_texture("default", 0)

func _input(event: InputEvent) -> void:
	var new_input_mode: InputMode
	if event is InputEventKey:
		new_input_mode = InputMode.KEYBOARD
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		var name := Input.get_joy_name(event.device).to_lower()
		if "nintendo" in name or "switch" in name or "joy-con"  in name:
			new_input_mode = InputMode.NINTENDO
		elif "sony" in name or "dualshock" in name or "dualsense" in name or "ps5" in name or "ps4" in name or "ps3" in name:
			new_input_mode = InputMode.PLAYSTATION
		else:
			new_input_mode = InputMode.XBOX
	
	if new_input_mode != current_input_mode:
		current_input_mode = new_input_mode
		input_mode_changed.emit()
