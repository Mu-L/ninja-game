@abstract
class_name SkillSelectionArea extends Area2D

enum TargetType {ALLIES, ENEMIES}

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@export var shape_color: Color
@export var target_type: TargetType
var battlers: Array[Battler] = []

func _on_area_entered(area: Area2D) -> void:
	if (target_type == TargetType.ALLIES and area is AllyBattler 
	or target_type == TargetType.ENEMIES and area is EnemyBattler):
		area.play_blinking_animation()
		battlers.append(area)

func _on_area_exited(area: Area2D) -> void:
	if area is Battler:
		area.stop_blinking_animation()
		battlers.erase(area)

@abstract
func highlight_target(attacker: AllyBattler, target: Battler) -> void
