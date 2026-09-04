class_name Player extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var weapon_sound: AudioStreamPlayer = %WeaponSound
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var hurt_sound: AudioStreamPlayer = %HurtSound
@onready var debug_label: Label = %DebugLabel
@onready var weapon_timer: Timer = %WeaponTimer
@onready var health_bar: ProgressBar = %HealthBar

@onready var weapons: Node2D = %Weapons
@onready var weapon_down: WeaponScene = %WeaponDown
@onready var weapon_right: WeaponScene = %WeaponRight
@onready var weapon_up: WeaponScene = %WeaponUp
@onready var weapon_left: WeaponScene = %WeaponLeft

@export var movement_speed: int = 100
@export var attack_duration := 0.5
@export var party_members_data: Array[AllyBattlerData] = []

var followers: Array[Follower]
var position_history: Array[Vector2] = []
var position_index := 0

class Direction:
	
	enum Directions {LEFT, RIGHT, UP, DOWN}
	var direction: Directions
	var vector: Vector2
	var string: String
	var current_weapon: Area2D
	
	func _init(dir: Directions, player: Player) -> void:
		self.direction = dir
		match dir:
			Directions.LEFT:
				vector = Vector2.LEFT
				string = "left"
				player.current_weapon = player.weapon_left
			Directions.RIGHT:
				vector = Vector2.RIGHT
				string = "right"
				player.current_weapon = player.weapon_right
			Directions.UP:
				vector = Vector2.UP
				string = "up"
				player.current_weapon = player.weapon_up
			Directions.DOWN:
				vector = Vector2.DOWN
				string = "down"
				player.current_weapon = player.weapon_down

var direction: Direction
var is_attacking := false
var is_interacting := false
var current_weapon: WeaponScene

func _ready() -> void:
	EventBus.battle_finished.connect(_on_battle_finished)
	for weapon: WeaponScene in weapons.get_children():
		weapon.body_entered.connect(_on_hurtbox_body_entered)
	direction = Direction.new(Direction.Directions.DOWN, self)
	for data in party_members_data:
		data.health = data.max_health
		data.magic_points = data.max_magic_points
	var i := 1
	while i < len(party_members_data):
		followers.append(Follower.create(party_members_data[i], self, 100-15*i))
		i += 1
	position_history.resize(100)
	position_history.fill(global_position)

func _physics_process(delta: float) -> void:
	if is_interacting:
		return
	if not is_attacking:
		movement_logic_and_animation(delta)
	attack_logic_and_animation(delta)
	move_and_slide()
	update_position_history()

func update_position_history() -> void:
	if velocity != Vector2.ZERO:
		position_history[position_index % position_history.size()] = global_position
		position_index += 1

func movement_logic_and_animation(_delta: float) -> void:
	
	var nothing_pressed := false
	if Input.is_action_pressed("move right"):
		direction = Direction.new(Direction.Directions.RIGHT, self)
	elif Input.is_action_pressed("move left"):
		direction = Direction.new(Direction.Directions.LEFT, self)
	elif Input.is_action_pressed("move down"):
		direction = Direction.new(Direction.Directions.DOWN, self)
	elif Input.is_action_pressed("move up"):
		direction = Direction.new(Direction.Directions.UP, self)
	else:
		nothing_pressed = true
	
	var animation_name: String
	if nothing_pressed:
		velocity = Vector2.ZERO
		animation_name = "idle %s" % direction.string
	else:
		velocity = direction.vector * movement_speed
		animation_name = "walk %s" % direction.string
	animated_sprite_2d.play(animation_name)

func attack_logic_and_animation(_delta: float) -> void:
	if Input.is_action_just_pressed("attack") and not is_attacking:
		is_attacking = true
		velocity = Vector2.ZERO
		var animation_name := "attack %s" % direction.string
		animated_sprite_2d.play(animation_name)
		weapon_sound.play()
		
		current_weapon.show()
		current_weapon.set_hitbox(false)
		weapon_timer.start(attack_duration)
		

func _on_weapon_timer_timeout() -> void:
	current_weapon.hide()
	current_weapon.set_hitbox(true)
	is_attacking = false


func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body is Enemy:
		health_bar.hide()
		EventBus.start_battle.emit(body, self)
		body.call_deferred("done")

func _on_battle_finished() -> void:
	while party_members_data[0].health <= 0:
		var leader = party_members_data.pop_front()
		party_members_data.push_back(leader)
		
		animated_sprite_2d.sprite_frames = party_members_data[0].sprite_frames
		for i in range(len(followers)):
			followers[i].set_data(party_members_data[i+1])
