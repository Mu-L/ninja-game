class_name Player extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var weapon_sound: AudioStreamPlayer = %WeaponSound
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var hurt_sound: AudioStreamPlayer = %HurtSound
@onready var knockback_component: KnockbackCompnent = %KnockbackComponent
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
@export var battle_data: BattlerData

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
var current_weapon: WeaponScene

func _ready() -> void:
	for weapon: WeaponScene in weapons.get_children():
		weapon.body_entered.connect(_on_weapon_body_entered)
	direction = Direction.new(Direction.Directions.DOWN, self)
	set_health(battle_data.max_health)

func _physics_process(delta: float) -> void:
	if not is_attacking:
		movement_logic_and_animation(delta)
	attack_logic_and_animation(delta)
	move_and_slide()

func movement_logic_and_animation(_delta: float) -> void:
	
	var input_vector = Input.get_vector("move left", "move right","move up", "move down")
	velocity = input_vector * movement_speed + knockback_component.force
	
	if input_vector.x > 0:
		direction = Direction.new(Direction.Directions.RIGHT, self)
	if input_vector.x < 0:
		direction = Direction.new(Direction.Directions.LEFT, self)
	if input_vector.y > 0:
		direction = Direction.new(Direction.Directions.DOWN, self)
	if input_vector.y < 0:
		direction = Direction.new(Direction.Directions.UP, self)
	
	var animation_name: String
	if input_vector == Vector2.ZERO:
		animation_name = "idle %s" % direction.string
	else:
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

func _on_damageable_component_took_damage(amount: int) -> void:
	battle_data.health -= amount
	animation_player.play("hurt")
	hurt_sound.play()
	if battle_data.health <= 0:
		queue_free()

func _on_weapon_body_entered(body: Node2D) -> void:
	if body is Enemy:
		health_bar.hide()
		Global.start_battle.emit(body, self)

func set_health(new_val) -> void:
	battle_data.health = new_val
	health_bar.value = new_val

func _on_weapon_timer_timeout() -> void:
	current_weapon.hide()
	current_weapon.set_hitbox(true)
	is_attacking = false
