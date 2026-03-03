extends Node2D

@onready var battle_start_sound: AudioStreamPlayer = %BattleStartSound
@onready var over_world: Node2D = %Room2

func _ready() -> void:
	Global.start_battle.connect(_on_battle_start)

func _on_battle_start(enemy: Enemy, player: Player) -> void:
	over_world.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	battle_start_sound.play()
	await battle_start_sound.finished
	over_world.hide()
	const BATTLE := preload("uid://cb3474ae6wcck")
	var battle: Battle = BATTLE.instantiate()
	battle.enemy_data = enemy.battle_data
	battle.player_data = player.battle_data
	add_child(battle)
	battle.battle_finished.connect(
		func():
			over_world.set_deferred("process_mode", Node.PROCESS_MODE_INHERIT)
			player._on_weapon_timer_timeout()
			over_world.show()
			battle.queue_free()
			enemy.die()
			var player_battler: PlayerBattler = get_tree().get_first_node_in_group("player battler")
			if not player_battler:
				return
			player.health_bar.show()
			player.set_health(player.battle_data.health)
	)
