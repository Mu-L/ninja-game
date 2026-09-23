class_name LevelUpUI extends VBoxContainer

@onready var battler_portrait: TextureRect = %BattlerPortrait
@onready var battler_name_label: RichTextLabel = %BattlerNameLabel
@onready var stats_container: GridContainer = %StatsContainer
@onready var skill_icon: TextureRect = %SkillIcon
@onready var skill_name: Label = %SkillName
@onready var new_skill_ui: NinePatchRect = %NewSkillUI
@onready var new_skill_label: RichTextLabel = %NewSkillLabel

var level_up: LevelUp
var ally_data: AllyData

static func create(ally_data: AllyData, level_up: LevelUp) -> LevelUpUI:
	const LEVEL_UP_UI = preload("uid://cjmfi1pd467bv")
	var instance: LevelUpUI = LEVEL_UP_UI.instantiate()
	instance.level_up = level_up
	instance.ally_data = ally_data
	return instance

func _ready() -> void:
	battler_name_label.text = Util.BBCode_wave(
		battler_name_label.text % [
			ally_data.name,
			ally_data.level
		]
	)
	new_skill_label.text = Util.BBCode_wave(
		new_skill_label.text
	)
	battler_portrait.texture = ally_data.portrait
	if level_up.new_skill:
		new_skill_ui.show()
		new_skill_label.show()
		skill_icon.texture = level_up.new_skill.icon
		skill_name.text = level_up.new_skill.name
	for stat in level_up.stat_increases.keys():
		var stat_name_label := Label.new()
		stat_name_label.text = LevelUp.SHORT_HAND_NAMES[stat]
		stats_container.add_child(stat_name_label)
		var stat_amount_label := Label.new()
		stat_amount_label.text = "+%d" % level_up.stat_increases[stat]
		stats_container.add_child(stat_amount_label)
