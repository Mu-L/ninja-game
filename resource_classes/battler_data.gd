@tool
@abstract
class_name BattlerData extends Resource

@export_category("stats")
@export var max_health: int = 100
@export var strength: int = 25
@export var defense: int = 20
@export var speed: int = 20

var health: int = self.max_health

@export_category("visuals")
@export var name: String
@export var texture: Texture2D
@export var sprite_frames: SpriteFrames
@export var animation_speed: float = 5.0
@export_tool_button("generate sprite_frames boilerplate") var button := func():
	sprite_frames = Util.generate_sprite_frames(animation_speed, texture)
