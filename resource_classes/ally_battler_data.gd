@tool
class_name AllyBattlerData extends BattlerData

@export var max_magic_points: int = 25
@export var EXP_to_next_level: int = 100
@export var skills: Array[Skill]
@export var weapon: Weapon
@export var level_ups: Array[LevelUp]
@export var text_color: Color = Color.BLUE_VIOLET
@export_tool_button("generate sprite_frames animations from texture") var button := func():
	sprite_frames = Util.generate_sprite_frames(texture, true, animation_speed, flying)


var magic_points: int
var EXP: int = 0
var level: int = 1
