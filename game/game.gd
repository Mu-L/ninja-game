extends Node2D

@onready var battle_start_sound: AudioStreamPlayer = %BattleStartSound
@onready var over_world: Node2D = $Room3
@onready var music: AudioStreamPlayer = %Music

func _ready() -> void:
	Global.start_battle.connect(_on_battle_start)

func _on_battle_start(enemy: Enemy, player: Player) -> void:
	over_world.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	music.stream_paused = true
	battle_start_sound.play()
	await battle_start_sound.finished
	over_world.hide()
	var battle := Battle.create(player.party_members_data, enemy.battle_data)
	add_child(battle)
	battle.start()
	await Global.battle_finished
	# Update ally stats:
	player.party_members_data = battle.allies_data
	over_world.set_deferred("process_mode", Node.PROCESS_MODE_PAUSABLE)
	music.stream_paused = false
	player._on_weapon_timer_timeout()
	over_world.show()
	battle.queue_free()
	enemy.die()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
