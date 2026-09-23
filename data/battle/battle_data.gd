@tool
class_name BattleData extends Resource

enum BackgroundType {FIELD}

const BACKGROUNDS: Dictionary[BackgroundType, PackedScene] = {
	BackgroundType.FIELD : preload("uid://di4o3id6winmt")
}

func create_empty_enemies_grid():
	enemies_data_grid = []
	for i in range(grid_size):
		var row := EnemyDataRow.new()
		enemies_data_grid.append(row)
		row.elements.resize(grid_size)

@export_tool_button("Create empty enemies grid") var a = create_empty_enemies_grid
@export_range(1, 10) var grid_size: int = 3
@export var enemies_data_grid: Array[EnemyDataRow]
@export var overworld_enemy_index := Vector2i.ZERO
@export var background_type: BackgroundType
@export var song: AudioStream
