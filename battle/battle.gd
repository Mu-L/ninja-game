class_name Battle extends Node2D

@onready var battlers: Node2D = %Battlers
@onready var text_box: TextureRect = %TextBox
@onready var battle_text: Label = %BattleText
@onready var battle_camera: Camera2D = %BattleCamera
@onready var music: AudioStreamPlayer = %Music
@onready var ally_spawn_circle: Marker2D = %AllySpawnCircle
@onready var ally_spawn_point: Marker2D = %AllySpawnPoint
@onready var enemy_spawn_circle: Marker2D = %EnemySpawnCircle
@onready var enemy_spawn_point: Marker2D = %EnemySpawnPoint

signal battle_finished

var enemies_data: Array[EnemyBattlerData]
var allies_data: Array[AllyBattlerData]
var _num_of_living_allies := 0
var _num_of_living_enemies := 0
var _allies: Array[AllyBattler] = []
var _enemies: Array[EnemyBattler] = []

static func create(allies_data: Array[AllyBattlerData], enemies_data: Array[EnemyBattlerData]) -> Battle:
	const BATTLE = preload("uid://cb3474ae6wcck")
	var battle: Battle = BATTLE.instantiate()
	battle.allies_data = allies_data
	battle.enemies_data = enemies_data
	return battle

func start() -> void:
	Global.display_text.connect(display_text)
	
	# Spawn allies:
	for i in range(allies_data.size()):
		var ally := Battler.create(allies_data[i])
		battlers.add_child(ally)
		_num_of_living_allies += 1
		_allies.append(ally)
		if allies_data.size() == 1:
			ally.global_position = ally_spawn_circle.global_position
		else:
			var step := 360.0 / allies_data.size()
			ally_spawn_circle.rotation_degrees = step * i
			ally.global_position = ally_spawn_point.global_position
	
	# Spawn enemies:
	for i in range(enemies_data.size()):
		var enemy := Battler.create(enemies_data[i])
		battlers.add_child(enemy)
		_num_of_living_enemies += 1
		_enemies.append(enemy)
		if enemies_data.size() == 1:
			enemy.global_position = enemy_spawn_circle.global_position
		else:
			var step := 360.0 / enemies_data.size()
			enemy_spawn_circle.rotation_degrees += step * i
			enemy.global_position = enemy_spawn_point.global_position
	
	battle_camera.make_current()
	text_box.hide()
	while not is_battle_finished():
		await get_tree().create_timer(0.1).timeout
		for battler: Battler in battlers.get_children():
			battler.decide_action()
			if battler is AllyBattler:
				await battler.finished_deciding_action
		
		for battler: Battler in battlers.get_children():
			battler.perform_action()
			await battler.finished_performing_action
			if is_battle_finished():
				break
	finish_battle()

func display_text(text: String) -> void:
	$DisplayTextSound.play()
	text_box.show()
	battle_text.text = text

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") and text_box.visible:
		text_box.hide()
		Global.textbox_closed.emit()

func is_battle_finished() -> bool:
	return _num_of_living_allies == 0 or _num_of_living_enemies == 0

func finish_battle() -> void:
	music.stop()
	if _num_of_living_enemies == 0:
		display_text("Player Won !")
		await Global.textbox_closed
		text_box.hide()
		for ally in _allies:
			await ally.increase_exp(100)
		battle_finished.emit()
	else:
		display_text("Game Over...")
		await Global.textbox_closed
		get_tree().change_scene_to_file("res://game/game.tscn")
