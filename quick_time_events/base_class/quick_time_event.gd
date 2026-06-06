@abstract
class_name QuickTimeEvent extends Node2D

signal finished

var started: bool = false
var ally: AllyBattler
var ally_starting_pos: Vector2
var target: Battler
var targets: Array[Battler]

func start(ally: AllyBattler) -> void:
	started = true
	self.ally = ally
	ally_starting_pos = ally._starting_pos
	target = ally.get_main_target_battler()
	targets = ally.targets
