class_name Overworld extends Node2D

@onready var followers: Node2D = %Followers
@onready var player: Player = %Player
@onready var label: Label = $CanvasLayer/Label

func _ready() -> void:
	for i in range(player.followers.size()):
		followers.add_child(player.followers[i])

func _process(delta: float) -> void:
	label.text = ""
	for follower in followers.get_children():
		label.text += "%d\n" % (follower as Follower).step_delay
