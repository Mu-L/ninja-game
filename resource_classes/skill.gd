class_name Skill extends Resource

@export var name: String
@export_multiline() var battle_text: String
@export var magic_points_cost: int
@export var selection_type: AllyBattler.SelectionType
@export var selection_area: PackedScene
@export var quick_time_event: PackedScene
