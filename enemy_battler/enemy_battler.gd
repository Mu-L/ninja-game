class_name EnemyBattler extends Battler

func _ready() -> void:
	super._ready()
	animated_sprite_2d.play("idle left")

func play_turn() -> void:
	update_battlers_arrays()
	action_to_perform = ActionType.ATTACK
	_action_text = "%s attacked green ninja!" % battler_name
	if action_to_perform == ActionType.ATTACK:
		var ally: AllyBattler = _living_allies.pick_random()
		Global.display_text.emit(_action_text)
		await Global.textbox_closed
		health_bar.hide()
		_starting_pos = self.global_position
		var final_pos := ally.global_position + Vector2(25, 0)
		var tween := create_tween().set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "global_position", final_pos, 0.5)
		await tween.finished
		animated_sprite_2d.sprite_frames.set_animation_loop("walk left", false)
		animated_sprite_2d.play("walk left")
		await animated_sprite_2d.animation_finished
		animated_sprite_2d.sprite_frames.set_animation_loop("walk left", true)
		await ally.take_damage(_strength)
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
