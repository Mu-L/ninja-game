extends Node2D

@onready var battle_start_sound: AudioStreamPlayer = %BattleStartSound
@onready var over_world: Node2D = $Room3
@onready var music: AudioStreamPlayer = %Music
@onready var black_screen: ColorRect = %BlackScreen
@onready var transition_material: ShaderMaterial

func _ready() -> void:
	EventBus.start_battle.connect(_on_battle_start)
	transition_material = black_screen.material

func _on_battle_start(enemy: Enemy, player: Player) -> void:
	over_world.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	music.stream_paused = true
	battle_start_sound.play()
	await play_battle_transition_effect(true)
	over_world.hide()
	var battle := Battle.create(player.party_members_data, enemy.battle_data)
	add_child(battle)
	await play_battle_transition_effect(false)
	battle.start()
	await EventBus.battle_finished

	music.stream_paused = false
	await play_battle_transition_effect(true)
	player.party_members_data = battle.allies_data
	over_world.set_deferred("process_mode", Node.PROCESS_MODE_PAUSABLE)
	player._on_weapon_timer_timeout()
	enemy.die()
	over_world.show()
	battle.queue_free()
	await play_battle_transition_effect(false)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

func play_battle_transition_effect(invert: bool, duration:=0.75) -> void:
	var tween := create_tween()
	tween.tween_property(transition_material, "shader_parameter/invert", invert, 0.01)
	tween.tween_property(transition_material, "shader_parameter/progress", 10, duration).from(0)
	await tween.finished
