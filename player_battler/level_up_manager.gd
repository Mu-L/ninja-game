class_name LevelUpManager extends Node

class Upgrade:
	
	var stats: Dictionary[String, int]
	var new_skills: Array[Skill]
	
	@warning_ignore("shadowed_variable")
	func _init(stats: Dictionary[String, int], new_skills: Array[Skill]) -> void:
		self.new_skills = new_skills
		self.stats = stats

var upgrades: Dictionary[int, Upgrade] = {
	2 : Upgrade.new({
		"max_health" : 25,
		"strength" : 10
	}, [preload("res://skills/shuriken.tres")]),
	
	3 : Upgrade.new({
		"max_health" : 27,
		"strength" : 9,
		"speed" : 4
	}, [preload("res://skills/kunai.tres")]),
	
	4 : Upgrade.new({
		"max_health" : 18,
		"strength" : 7,
		"speed" : 3
	}, []),
}
