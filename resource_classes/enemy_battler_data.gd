@tool
class_name EnemyBattlerData extends BattlerData

@export var exp_worth: int = 100
@export_tool_button("generate sprite_frames boilerplate") var b := func():
	sprite_frames = Util.generate_sprite_frames(texture, false, animation_speed, flying, weird)
