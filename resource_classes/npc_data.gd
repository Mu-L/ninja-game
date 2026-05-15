@tool
class_name NPCData extends Resource

@export var name: String
@export var sprite_frames: SpriteFrames
@export var portait: Texture2D
@export var texture: Texture2D
@export_multiline var dialouge: Array[String]
@export var animation_speed := 5.0

@export_tool_button("generate sprite_frames boilerplate") var button := func():
	sprite_frames = Util.generate_sprite_frames(animation_speed, texture)
