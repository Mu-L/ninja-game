class_name BattleData extends Resource

enum BackgroundType {FIELD}

const BACKGROUNDS: Dictionary[BackgroundType, PackedScene] = {
	BackgroundType.FIELD : preload("uid://di4o3id6winmt")
}

@export var enemy_positions: Dictionary[Vector2, EnemyBattlerData]
@export var background_type: BackgroundType
@export var song: AudioStream
