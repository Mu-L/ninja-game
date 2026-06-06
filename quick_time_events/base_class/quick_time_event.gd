@abstract
class_name QuickTimeEvent extends Node2D

signal finished

var started: bool = false

@abstract
func start(ally: AllyBattler) -> void
