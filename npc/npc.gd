class_name NPC extends CharacterBody2D

@export var data: NPCData
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	animated_sprite_2d.sprite_frames = data.sprite_frames

func _on_interact_component_interacted() -> void:
	
	var player: Player = get_tree().get_first_node_in_group("player")
	var dir := global_position.direction_to(player.global_position)
	
	if dir.x > 0:
		animated_sprite_2d.play('idle right')
	if dir.x < 0:
		animated_sprite_2d.play("idle left")
	
	if abs(dir.y ) > abs(dir.x):
		if dir.y > 0:
			animated_sprite_2d.play('idle down')
		if dir.y < 0:
			animated_sprite_2d.play("idle up")
	
	DialogueBox.display_dialogue(data.dialouge.duplicate(), data.portait)
