class_name Battle extends Node2D

@onready var battlers: Node2D = %Battlers
@onready var text_box: ColorRect = %TextBox
@onready var battle_text: Label = %BattleText
@onready var player_battler: PlayerBattler = %PlayerBattler
@onready var enemy_battler: EnemyBattler = %EnemyBattler
@onready var battle_camera: Camera2D = %BattleCamera

signal battle_finished

var enemy_data: BattlerData
var player_data: BattlerData

func _ready() -> void:
	Global.display_text.connect(display_text)
	enemy_battler.data = enemy_data
	player_battler.data = player_data
	battle_camera.make_current()
	text_box.hide()
	while not is_battle_finished():
		await get_tree().create_timer(0.1).timeout
		for battler: Battler in battlers.get_children():
			battler.decide_action()
			if battler is PlayerBattler:
				await battler.finished_deciding_action
		
		for battler: Battler in battlers.get_children():
			display_text(battler.action_text)
			await Global.textbox_closed
			text_box.hide()
			battler.perform_action()
			await battler.finished_performing_action
			if is_battle_finished():
				break
	finish_battle()

func display_text(text: String) -> void:
	$DisplayTextSound.play()
	text_box.show()
	battle_text.text = text

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		Global.textbox_closed.emit()

func is_battle_finished() -> bool:
	return not enemy_battler or not player_battler

func finish_battle() -> void:
	if not enemy_battler:
		display_text("Player Won !")
		await Global.textbox_closed
		text_box.hide()
		await player_battler.increase_exp(100)
	else:
		display_text("Game Over...")
		await Global.textbox_closed
		get_tree().quit()
	battle_finished.emit()
