extends CanvasLayer

@onready var label: RichTextLabel = %DialogueLabel
@onready var text_sound: AudioStreamPlayer = %TextSound
@onready var timer: Timer = %Timer
@onready var portrait: TextureRect = %Portrait

var lines_to_display: Array[String]

func _ready() -> void:
	self.hide()

func display_dialogue(dialogue: Array[String], portrait_texture: Texture) -> void:
	portrait.texture = portrait_texture
	lines_to_display = dialogue
	self.show()
	scroll_line(lines_to_display.pop_front())

func scroll_line(line: String) -> void:
	clear_text()
	label.text = line
	timer.start()

func _process(_delta: float) -> void:
	if not InteractableComponent.is_interacting:
		return
	if Input.is_action_just_pressed("interact"):
		if lines_to_display.size() == 0:
			clear_text()
			self.hide()
			await get_tree().create_timer(0.1).timeout
			InteractableComponent.is_interacting = false
			get_tree().paused = false
		else:
			scroll_line(lines_to_display.pop_front())

func clear_text() -> void:
	timer.stop()
	label.text = ""
	label.visible_ratio = 0.0

func _on_timer_timeout() -> void:
	if label.visible_ratio == 1.0 or len(label.get_parsed_text()) == 0:
		timer.stop()
		return
	text_sound.play()
	label.visible_characters += 1
	timer.start()
