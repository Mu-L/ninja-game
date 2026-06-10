class_name Battle extends Node2D

@onready var battlers: Node2D = %Battlers
@onready var text_box: TextureRect = %TextBox
@onready var battle_text: Label = %BattleText
@onready var battle_camera: Camera2D = %BattleCamera
@onready var music: AudioStreamPlayer = %Music
@onready var ally_spawn_circle: Marker2D = %AllySpawnCircle
@onready var ally_spawn_point: Marker2D = %AllySpawnPoint
@onready var enemy_spawn_origin_point: Marker2D = %EnemySpawnOriginPoint


signal battle_finished

var battle_data: BattleData
var allies_data: Array[AllyBattlerData]
var _allies: Array[AllyBattler] = []
var _enemies: Array[EnemyBattler] = []
var _num_of_living_allies := 0
var _num_of_living_enemies := 0

static func create(allies_data: Array[AllyBattlerData], battle_data: BattleData) -> Battle:
	const BATTLE = preload("uid://cb3474ae6wcck")
	var battle: Battle = BATTLE.instantiate()
	battle.allies_data = allies_data
	battle.battle_data = battle_data
	return battle

func start() -> void:
	Global.display_text.connect(display_text)
	
	# Spawn background:
	var background_scene := BattleData.BACKGROUNDS[battle_data.background_type]
	var background: Node2D = background_scene.instantiate()
	add_child(background)
	
	# Spawn allies:
	for i in range(allies_data.size()):
		var ally := Battler.create(allies_data[i]) as AllyBattler
		battlers.add_child(ally)
		_num_of_living_allies += 1
		ally.died.connect(func(): _num_of_living_allies -= 1)
		_allies.append(ally)
		if allies_data.size() == 1:
			ally.global_position = ally_spawn_circle.global_position
		else:
			var step := 360.0 / allies_data.size()
			ally_spawn_circle.rotation_degrees = step * i
			ally.global_position = ally_spawn_point.global_position
	
	# Spawn enemies:
	for enemy_pos: Vector2 in battle_data.enemy_positions:
		var enemy_data := battle_data.enemy_positions[enemy_pos]
		var enemy := Battler.create(enemy_data) as EnemyBattler
		battlers.add_child(enemy)
		_num_of_living_enemies += 1
		enemy.died.connect(func(): _num_of_living_enemies -= 1)
		_enemies.append(enemy)
		enemy.global_position = (
			enemy_spawn_origin_point.global_position + enemy_pos)
	
	battle_camera.make_current()
	text_box.hide()
	while not is_battle_finished():
		for battler: Battler in battlers.get_children():
			if not battler.is_alive:
				continue
			battler.play_turn()
			await battler.finished_turn
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

func allies_won() -> bool:
	return _num_of_living_enemies == 0

func enemies_won() -> bool:
	return _num_of_living_allies == 0 

func is_battle_finished() -> bool:
	return allies_won() or enemies_won()

func finish_battle() -> void:
	music.stop()
	if allies_won():
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
