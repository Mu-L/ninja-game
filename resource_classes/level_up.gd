class_name LevelUp extends Resource

enum Stat {
	MAX_HEALTH,
	MAX_MAGIC_POINTS,
	STRENGTH,
	DEFENSE
}

const SHORT_HAND_NAMES: Dictionary[Stat, String] = {
	Stat.MAX_HEALTH : "HP",
	Stat.MAX_MAGIC_POINTS : "MP",
	Stat.STRENGTH : "STR",
	Stat.DEFENSE : "DEF"
}

@export var stat_increases: Dictionary[Stat, int]
@export var new_skill: Skill
