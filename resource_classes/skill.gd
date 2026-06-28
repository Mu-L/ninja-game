class_name Skill extends Resource

@export var name: String
@export var icon: Texture
@export var disabled_icon: Texture
@export_multiline() var battle_text: String
@export var magic_points_cost: int
@export var selection_type: AllyBattler.SelectionType
@export var selection_area: PackedScene
@export var quick_time_event: PackedScene
@export var constraints: Array[Constraints]

enum Constraints {
	TARGET_MUST_BE_ALIVE,
	TARGET_MUST_BE_DEAD,
	
}
