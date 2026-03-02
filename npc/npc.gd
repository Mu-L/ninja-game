class_name NPC extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

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
	
	DialogueBox.display_dialogue([
		"Hey what's up dude.",
		"Have you seen the new game in town ?",
		"It's called 'Ninja Adventure'.",
		"I think it sounds pretty rad!"
	])
