class_name Battle extends Node2D

@export var distance_between_enemies := 40

@onready var battlers: Node2D = %Battlers
@onready var text_box: TextureRect = %TextBox
@onready var battle_text: RichTextLabel = %BattleText
@onready var battle_camera: Camera2D = %BattleCamera
@onready var music: AudioStreamPlayer = %Music
@onready var ally_spawn_circle: Marker2D = %AllySpawnCircle
@onready var ally_spawn_point: Marker2D = %AllySpawnPoint
@onready var enemy_spawn_origin_point: Marker2D = %EnemySpawnOriginPoint
@onready var rotation_count_label: Label = %RotationCountLabel
@onready var error_sound: AudioStreamPlayer = %ErrorSound
@onready var rotation_timer: Timer = %RotationTimer
@onready var battler_portrait: TextureRect = %BattlerPortrait
@onready var battler_name_label: Label = %BattlerNameLabel
@onready var health_receptacle: Receptacle = %HealthReceptacle
@onready var magic_receptacle: Receptacle = %MagicReceptacle
@onready var battler_health_label: Label = %BattlerHealthLabel
@onready var battler_magic_label: Label = %BattlerMagicLabel
@onready var health_container: HBoxContainer = $UI/BattlerDataUI/VboxContainer/HealthContainer
@onready var magic_container: HBoxContainer = $UI/BattlerDataUI/VboxContainer/MagicContainer
@onready var battler_data_ui: NinePatchRect = %BattlerDataUI

signal battle_finished

var battle_data: BattleData
var allies_data: Array[AllyBattlerData]
var _allies: Array[AllyBattler] = []
var enemies_grid: Array[EnemyBattlerRow] = []
var has_not_played_turn: Array[AllyBattler] = []
var _num_of_living_allies := 0
var _num_of_living_enemies := 0
var exp_gained: int
var _ally_selection_index := 0
var turn: Turn
var number_of_rotations_left := 0

# flags"
var is_selcting_ally := false
var _is_choosing_rotation := false
var _is_rotating := false

enum Turn {ALLIES, ENEMIES}

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
	
	enemies_grid = []
	for i in range(battle_data.grid_size):
		var row := EnemyBattlerRow.new()
		enemies_grid.append(row)
		row.elements.resize(battle_data.grid_size)
	
	# Spawn allies:
	for i in range(allies_data.size()):
		var ally := Battler.create(allies_data[i]) as AllyBattler
		ally._enemies_grid = enemies_grid
		battlers.add_child(ally)
		_num_of_living_allies += 1
		ally.died.connect(func(): _num_of_living_allies -= 1)
		ally.finished_turn.connect(_on_ally_finished_turn)
		ally.update_battler_ui.connect(update_battler_data_ui)
		_allies.append(ally)
		if allies_data.size() == 1:
			ally.global_position = ally_spawn_circle.global_position
		else:
			var step := 360.0 / 4
			ally_spawn_circle.rotation_degrees += step
			ally.global_position = ally_spawn_point.global_position
	
	# Spawn enemies:
	for i in range(battle_data.enemies_data_grid.size()):
		var row := battle_data.enemies_data_grid[i].elements
		for j in range(row.size()):
			if row[j] == null:
				continue
			exp_gained += row[j].exp_worth
			var enemy := Battler.create(row[j]) as EnemyBattler
			battlers.add_child(enemy)
			_num_of_living_enemies += 1
			enemy.died.connect(func(): _num_of_living_enemies -= 1)
			enemies_grid[i].elements[j] = enemy
			enemy.global_position = (
				enemy_spawn_origin_point.global_position + Vector2(
				distance_between_enemies * j,
				distance_between_enemies * i
			))
	
	battle_camera.make_current()
	text_box.hide()
	start_ally_turn()

func start_ally_turn() -> void:
	has_not_played_turn = _allies.filter(func(ally: AllyBattler): return ally.is_alive)
	number_of_rotations_left = 6
	turn = Turn.ALLIES
	is_selcting_ally = true
	Global.set_cursor_visible.emit(true)
	_ally_selection_index = _allies.find(has_not_played_turn[0])
	update_battler_data_ui(_allies[_ally_selection_index])
	Global.move_cursor_to.emit(has_not_played_turn[0].global_position)

func enemy_turn() -> void:
	turn = Turn.ENEMIES
	for row in enemies_grid:
		for enemy in row.elements:
			if not enemy or not enemy.is_alive:
				continue
			enemy.play_turn()
			await enemy.finished_turn
			if is_battle_finished():
				finish_battle()
				return
	start_ally_turn()

func _on_ally_finished_turn() -> void:
	await get_tree().create_timer(0.1).timeout
	if is_battle_finished():
		finish_battle()
		return
	if has_not_played_turn.size() == 0:
		for a in _allies:
			a.played_turn = false
			if a.is_alive:
				a.animated_sprite_2d.modulate.a = 1.0
		await get_tree().create_timer(0.1).timeout
		enemy_turn()
	else:
		is_selcting_ally = true
		Global.set_cursor_visible.emit(true)
		_ally_selection_index = _allies.find(has_not_played_turn[0])
		update_battler_data_ui(_allies[_ally_selection_index])
		Global.move_cursor_to.emit(has_not_played_turn[0].global_position)

func _input(event: InputEvent) -> void:
	
	if _is_rotating:
		return
	
	if text_box.visible and event.is_action_pressed("interact"):
		text_box.hide()
		Global.textbox_closed.emit()
	
	elif event.is_action_pressed("menu"):
		rotation_count_label.show()
		rotation_count_label.text = "Rotations Left: %d" % number_of_rotations_left
		is_selcting_ally = false
		_is_choosing_rotation = true
		Global.set_cursor_visible.emit(false)
	
	elif is_selcting_ally:
		if event.is_action_pressed("move right"):
			_ally_selection_index = 0
		if event.is_action_pressed("move down"):
			_ally_selection_index = 1
		if event.is_action_pressed("move left"):
			_ally_selection_index = 2
		if event.is_action_pressed("move up"):
			_ally_selection_index = 3
		Global.move_cursor_to.emit(_allies[_ally_selection_index].global_position)
		update_battler_data_ui(_allies[_ally_selection_index])
		
		if event.is_action_pressed("interact"):
			var ally := _allies[_ally_selection_index]
			if ally.played_turn or not ally.is_alive:
				ally.error_sound.play()
				return
			has_not_played_turn.erase(ally)
			is_selcting_ally = false
			await get_tree().create_timer(0.1).timeout
			ally.play_turn()
	
	elif _is_choosing_rotation:
		var dir: int
		if event.is_action_pressed("move down"):
			dir = -1
		if event.is_action_pressed("move up"):
			dir = 1
		if dir != 0:
			_is_rotating = true
			if number_of_rotations_left <= 0:
				error_sound.play()
				return
			number_of_rotations_left -= 1
			rotation_count_label.text = "Rotations Left: %d" % number_of_rotations_left
			rotation_timer.start(_allies[0].movement_speed)
			for i in range(_allies.size()):
				_allies[i].move_to(_allies[(i+dir) % _allies.size()].global_position)
			if dir == 1:
				var last: AllyBattler = _allies.pop_back()
				_allies.push_front(last)
			else:
				var first: AllyBattler = _allies.pop_front()
				_allies.append(first)
		elif event.is_action_pressed("attack"):
			_is_choosing_rotation = false
			rotation_count_label.hide()
			is_selcting_ally = true
			Global.set_cursor_visible.emit(true)
			Global.move_cursor_to.emit(_allies[0].global_position)

func update_battler_data_ui(battler: Battler) -> void:
	battler_data_ui.show()
	battler_name_label.text = battler.battler_name
	battler_portrait.texture = battler.portrait
	health_receptacle.update(float(battler._health) / battler._max_health)
	battler_health_label.text = "HP\n%d/%d" % [battler._health, battler._max_health]
	if battler is AllyBattler:
		magic_container.show()
		magic_receptacle.update(float(battler._magic_points) / battler._max_magic_points)
		battler_magic_label.text = "MP\n%d/%d" % [battler._magic_points, battler._max_magic_points]
	else:
		magic_container.hide()

func display_text(text: String) -> void:
	$DisplayTextSound.play()
	battler_data_ui.hide()
	text_box.show()
	battle_text.text = text

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
			if ally.is_alive:
				await ally.increase_exp(exp_gained)
		battle_finished.emit()
	else:
		display_text("Game Over...")
		await Global.textbox_closed
		get_tree().change_scene_to_file("res://game/game.tscn")


func _on_rotation_timer_timeout() -> void:
	_is_rotating = false
