@abstract
class_name SkillSelectionArea extends Area2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@export var shape_color: Color
var battlers: Array[Battler] = []

func _on_area_entered(area: Area2D) -> void:
	if area is Battler:
		area.play_selection_animation()
		battlers.append(area)

func _on_area_exited(area: Area2D) -> void:
	if area is Battler:
		area.stop_selection_animation()
		battlers.erase(area)

@abstract
func highlight_target(attacker: AllyBattler, target: Battler) -> void
