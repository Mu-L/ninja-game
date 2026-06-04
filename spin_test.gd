extends Node2D

@onready var progress_bar: ProgressBar = %ProgressBar
var actions: PackedStringArray = ["move up", "move right", "move down", "move left"]
var i := 0

func _process(_delta: float) -> void:
	if Input.is_action_pressed(actions[i % len(actions)]):
		i += 1
		progress_bar.value = i
