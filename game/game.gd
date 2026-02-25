extends Node2D

@onready var battle_start_sound: AudioStreamPlayer = %BattleStartSound
@onready var over_world: Node2D = %OverWorld

func _ready() -> void:
	Global.start_battle.connect(_on_battle_start)

func _on_battle_start(enemy: Enemy, player: Player) -> void:
	get_tree().paused = true
	battle_start_sound.play()
	await battle_start_sound.finished
	over_world.hide()
	const BATTLE := preload("uid://cb3474ae6wcck")
	var battle: Battle = BATTLE.instantiate()
	battle.enemy_data = enemy.battle_data
	battle.player_health = player.health
	add_child(battle)
	battle.battle_finished.connect(
		func():
			get_tree().paused = false
			over_world.show()
			battle.queue_free()
			enemy.die()
			var player_battler: PlayerBattler = get_tree().get_first_node_in_group("player battler")
			if not player_battler:
				return
			player.health_bar.show()
			player.health = player_battler.health
	)
