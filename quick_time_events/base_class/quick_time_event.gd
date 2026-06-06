@abstract
class_name QuickTimeEvent extends Node2D

signal finished(result: Dictionary[Battler, int])

var started: bool = false

@abstract
func start(ally: AllyBattler) -> void
