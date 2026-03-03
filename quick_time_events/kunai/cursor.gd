extends Node2D

@export var cursor_size: int = 7
@export var thickness: int = 3
@export var color: Color = Color.WHITE
@export var rotation_speed: int = 5

func _process(delta: float) -> void:
	rotate(delta * rotation_speed)

func _draw() -> void:
	draw_line(Vector2(-cursor_size, 0), Vector2(cursor_size, 0), color, thickness)
	draw_line(Vector2(0, cursor_size), Vector2(0, -cursor_size), color, thickness)
