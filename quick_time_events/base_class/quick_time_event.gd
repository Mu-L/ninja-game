@abstract
class_name QuickTimeEvent extends Node2D

signal finished(success: bool)

var started: bool = false

@abstract
func start() -> void
