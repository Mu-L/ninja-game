extends QuickTimeEvent

func start(ally: AllyBattler) -> void:
	super.start(ally)
	await ally.move_to(target.global_position - Vector2(25,0))
	ally.play_attack_anim()
	await target.take_damage(ally._strength, ally.weapon.multiplier)
	await ally.move_to(ally_starting_pos)
	finished.emit()
	
