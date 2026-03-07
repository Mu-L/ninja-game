class_name EnemyBattler extends Battler

func _ready() -> void:
	super._ready()

func set_data(new_val: BattlerData) -> void:
	super.set_data(new_val)
	animated_sprite_2d.play("idle left")
	set_health(data.max_health)

func decide_action() -> void:
	action_name = "attack"
	action_text = "%s attacked green ninja!" % data.name

func perform_action() -> void:
	if action_name == "attack":
		Global.display_text.emit(action_text)
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
		await player().take_damage(data.strength)
		animated_sprite_2d.play("idle left")
		tween = create_tween().set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "global_position", starting_pos, 0.5)
		await tween.finished
		health_bar.show()
		finished_performing_action.emit()

func player() -> PlayerBattler:
	return get_tree().get_first_node_in_group("player battler")
