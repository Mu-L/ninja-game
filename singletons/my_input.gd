extends Node

@onready var button_prompt_confirm: ButtonPrompt = %ButtonPromptConfirm
@onready var button_prompt_menu: ButtonPrompt = %ButtonPromptMenu
@onready var button_prompt_attack: ButtonPrompt = %ButtonPromptAttack
@onready var button_prompt_left: ButtonPrompt = %ButtonPromptLeft
@onready var button_prompt_right: ButtonPrompt = %ButtonPromptRight

@onready var button_prompts: Dictionary[String, ButtonPrompt] = {
	"[CONFIRM]" : button_prompt_confirm,
	"[ATTACK]" : button_prompt_attack,
	"[MENU]" : button_prompt_menu,
	"[LEFT]" : button_prompt_left,
	"[RIGHT]" : button_prompt_right
}

signal input_mode_changed(new_mode: InputMode)

enum InputMode {
	KEYBOARD,
	PLAYSTATION,
	XBOX,
	NINTENDO,
}

var current_input_mode := InputMode.KEYBOARD

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
		input_mode_changed.emit(new_input_mode)
