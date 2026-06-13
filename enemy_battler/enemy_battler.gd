class_name EnemyBattler extends Battler

func _ready() -> void:
	super._ready()
	animated_sprite_2d.play("idle left")

func play_turn() -> void:
	Global.set_cursor_visible.emit(true)
	Global.move_cursor_to.emit(self.global_position)
	update_battlers_arrays()
	action_to_perform = ActionType.ATTACK
	if action_to_perform == ActionType.ATTACK:
		var ally: AllyBattler = _living_allies.pick_random()
		Global.display_text.emit("%s attacked %s" % [battler_name, ally.battler_name])
		await Global.textbox_closed
		Global.set_cursor_visible.emit(false)
		health_bar.hide()
		_starting_pos = self.global_position
		var final_pos := ally.global_position + Vector2(25, 0)
		var tween := create_tween().set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "global_position", final_pos, 0.5)
		await tween.finished
		animated_sprite_2d.play("attack")
		await animated_sprite_2d.animation_finished
		await ally.take_damage(_strength, 1)
		animated_sprite_2d.play("idle left")
		tween = create_tween().set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "global_position", _starting_pos, 0.5)
		await tween.finished
		health_bar.show()
		finished_turn.emit()

func die() -> void:
	super.die()
	collision_shape_2d.set_deferred("disabled", true)
	create_tween().tween_property(self, "modulate:a", 0.0, 0.5)
