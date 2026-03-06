@tool
class_name BattlerData extends Resource

@export_category("stats")
@export var name: String
@export var max_health: int = 100
@export var max_magic_points: int = 25
@export var strength: int = 25
@export var EXP_to_next_level: int = 100
@export var skills: Array[Skill]

var health: int
var magic_points: int
var EXP: int = 0
var level: int = 1

@export_category("animation")
@export var sprite_frames: SpriteFrames
@export var animation_speed: float = 5.0
@export_tool_button("generate sprite_frames boilerplate") var button := func():
	sprite_frames = Util.generate_boilerplate_animation_names(animation_speed)
