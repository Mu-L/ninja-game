@tool
@abstract
class_name BattlerData extends Resource

@export_category("stats")
@export var max_health: int = 100
@export var strength: int = 10
@export var defense: int = 7
@export var speed: int = 20

var health: int

@export_category("visuals")
@export var name: String
@export var texture: Texture2D
@export var sprite_frames: SpriteFrames
@export var animation_speed: float = 5.0
