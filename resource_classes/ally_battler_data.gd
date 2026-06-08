@tool
class_name AllyBattlerData extends BattlerData

@export var max_magic_points: int = 25
@export var EXP_to_next_level: int = 100
@export var skills: Array[Skill]
@export var level_ups: Array[LevelUp]

var magic_points: int
var EXP: int = 0
var level: int = 1
