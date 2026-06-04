@abstract
class_name Skill extends Resource

enum SelectionType {SINGLE, NONE}

@export var name: String
@export_multiline() var battle_text: String
@export var magic_points_cost: int
@export var animation: SpriteFrames
@export var quick_time_event: PackedScene
@export var selection_type: SelectionType
@export var area_of_effect: PackedScene
