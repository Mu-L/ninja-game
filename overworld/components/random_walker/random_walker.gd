class_name RandomWalker extends Node2D

@onready var direction_change_timer: Timer = %DirectionChangeTimer
@onready var ray_cast_2d: RayCast2D = $RayCast2D

@export var body: CharacterBody2D
@export var animated_sprite_2d: AnimatedSprite2D
@export var movement_speed: int = 10
@export var min_direction_change_time: float = 2.0
@export var max_direction_change_time: float = 5.0

const DIRECTIONS := [Vector2.UP, Vector2.DOWN, Vector2.RIGHT, Vector2.LEFT]
var direction: Vector2

func _ready() -> void:
	_on_direction_change_timer_timeout()

func _physics_process(_delta: float) -> void:
	
	if ray_cast_2d.is_colliding():
		_on_direction_change_timer_timeout()
	
	body.velocity = direction * movement_speed
	body.move_and_slide()
	update_animation(direction)


func update_animation(direction: Vector2) -> void:
	match direction:
		Vector2.UP:
			animated_sprite_2d.play("walk up")
			ray_cast_2d.rotation_degrees = 180
		Vector2.DOWN:
			animated_sprite_2d.play("walk down")
			ray_cast_2d.rotation_degrees = 0
		Vector2.RIGHT:
			animated_sprite_2d.play("walk right")
			ray_cast_2d.rotation_degrees = 270
		Vector2.LEFT:
			animated_sprite_2d.play("walk left")
			ray_cast_2d.rotation_degrees = 90
		_:
			animated_sprite_2d.stop()

func direction_change_time() -> float:
	return randf_range(min_direction_change_time, max_direction_change_time)

func _on_direction_change_timer_timeout() -> void:
	direction = DIRECTIONS.pick_random()
	direction_change_timer.start(direction_change_time())
