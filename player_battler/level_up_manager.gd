class_name LevelUpManager extends Node

var upgrades: Dictionary[int, Dictionary] = {
	2 : {
		"max_health" : 25,
		"strength" : 10
	},
	3 : {
		"max_health" : 27,
		"strength" : 9,
		"speed" : 4
	},
	4 : {
		"max_health" : 18,
		"strength" : 7,
		"speed" : 3
	},
}
