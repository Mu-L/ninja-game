class_name LevelUp extends Resource

enum Stat {
	MAX_HEALTH,
	MAX_MAGIC_POINTS,
	STRENGTH,
	DEFENSE
}

@export var stat_increases: Dictionary[Stat, int]
@export var skills: Array[Skill]
