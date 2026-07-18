class_name Overworld extends Node2D

@onready var followers: Node2D = %Followers
@onready var player: Player = %Player

func _ready() -> void:
	for i in range(player.followers.size()):
		followers.add_child(player.followers[i])
