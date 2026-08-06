extends Node

@warning_ignore_start("unused_signal")

signal start_battle(enemy: Enemy, player: Player)

signal add_follower(follower: Follower)
signal display_text(text: String)
signal textbox_closed
signal move_cursor_to(pos: Vector2)
signal set_cursor_visible(val: bool)
signal give_extra_turn(ally: AllyBattler)
signal battle_finished

var is_cursor_moving := false
