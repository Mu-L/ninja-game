class_name EnemyBattler extends Battler

func _ready() -> void:
	super._ready()
	animated_sprite_2d.play("idle left")
	set_health(_max_health)

func decide_action() -> void:
	_action_name = "attack"
	_action_text = "%s attacked green ninja!" % battler_name

func perform_action() -> void:
	if _action_name == "attack":
		Global.display_text.emit(_action_text)
		await Global.textbox_closed
		health_bar.hide()
		var final_pos := player().global_position + Vector2(25, 0)
		var tween := create_tween().set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "global_position", final_pos, 0.5)
		await tween.finished
		animated_sprite_2d.sprite_frames.set_animation_loop("walk left", false)
		animated_sprite_2d.play("walk left")
		await animated_sprite_2d.animation_finished
		animated_sprite_2d.sprite_frames.set_animation_loop("walk left", true)
		await player().take_damage(_strength)
		animated_sprite_2d.play("idle left")
		tween = create_tween().set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "global_position", _starting_pos, 0.5)
		await tween.finished
		health_bar.show()
		finished_performing_action.emit()

func player() -> AllyBattler:
	return get_tree().get_first_node_in_group("player battler")
