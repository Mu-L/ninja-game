extends CanvasLayer

@onready var label: RichTextLabel = %DialogueLabel
@onready var text_sound: AudioStreamPlayer = %TextSound
@onready var timer: Timer = %Timer
@onready var portrait: TextureRect = %Portrait
@onready var name_label: Label = %NameLabel
@onready var button_prompt_confirm: ButtonPrompt = %ButtonPrompt

var lines_to_display: Array[String]

func _ready() -> void:
	self.hide()

func display_dialogue(dialogue: Array[String], portrait_texture: Texture, speaker_name: String) -> void:
	button_prompt_confirm.hide()
	portrait.texture = portrait_texture
	name_label.text = speaker_name
	lines_to_display = dialogue
	self.show()
	scroll_line(lines_to_display.pop_front())

func scroll_line(line: String) -> void:
	clear_text()
	label.text = line
	Util.format_button_icons_to_rich_text_label(label)
	timer.start()

func _process(_delta: float) -> void:
	if not InteractableComponent.is_interacting:
		return
	if Input.is_action_just_pressed("primary action"):
		if label.visible_ratio == 1.0:
			if lines_to_display.size() == 0:
				clear_text()
				self.hide()
				await get_tree().create_timer(0.1).timeout
				InteractableComponent.is_interacting = false
				get_tree().paused = false
			else:
				button_prompt_confirm.hide()
				scroll_line(lines_to_display.pop_front())
		else:
			label.visible_ratio = 1.0
			button_prompt_confirm.show()
			timer.stop()

func clear_text() -> void:
	timer.stop()
	label.text = ""
	label.visible_ratio = 0.0

func _on_timer_timeout() -> void:
	if label.visible_ratio == 1.0 or len(label.get_parsed_text()) == 0:
		timer.stop()
		button_prompt_confirm.show()
		return
	if label.visible_characters % 2 == 0:
		text_sound.play()
	label.visible_characters += 1
	timer.start()
