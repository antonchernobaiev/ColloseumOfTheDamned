extends CharacterBody2D

@export var knockback_duration:float = 0.30

const speed = 100.0
const knockback_force:int = 250

var is_alive:bool = true
var health:int = 100
var target = null
var last_direction: Vector2 = Vector2.DOWN
var is_attacking:bool = false
var can_attack:bool = false
var strength:int = 1 
var knockback_velocity:Vector2 = Vector2.ZERO
var knockback_timer:float = 0.0


@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var weapon: AnimatedSprite2D = $Weapon
@onready var weapon_range: Area2D = $WeaponRange
@onready var hitbox: Area2D = $Hitbox
@onready var take_damage_sound: AudioStreamPlayer2D = $TakeDamage
@onready var attack_sound: AudioStreamPlayer2D = $attack_sound
@onready var death: AnimatedSprite2D = $death


func _ready():
	add_to_group("enemies")


func _physics_process(_delta: float) -> void:
	if knockback_timer > 0.0:
		knockback_timer -= _delta
		if knockback_timer <= 0.0:
			knockback_velocity = Vector2.ZERO
	
	if is_alive:
		hitbox.monitoring = false
		
		if target and not is_attacking and knockback_timer <= 0:
			_track(_delta)
		process_animation()
		velocity = knockback_velocity
		move_and_slide()
		
		if not is_attacking and can_attack:
			attack()
			can_attack = false
	
	
func _track(_delta: float) -> void:
	var direction = Vector2(target.global_position - global_position).normalized()
	position += direction * speed * _delta
	last_direction = direction
	
func process_animation() -> void:
	if target and not is_attacking: 
		if target.position - position != Vector2.ZERO:
			play_animation("run", last_direction)
	else:
		play_animation("idle", last_direction)
		
		
func play_animation(prefix: String, dir: Vector2) -> void:
	if dir.x > 0 and dir.y > 0:
		if dir.x >= dir.y:
			animated_sprite_2d.play(prefix + "_right")
			hitbox.position = Vector2(11.8, 3.8)
			hitbox.scale = Vector2(0.4, 2.5)
		else:
			animated_sprite_2d.play(prefix + "_down")
			hitbox.position = Vector2(0, 15.5)
			hitbox.scale = Vector2(1,1)
	elif dir.x > 0 and dir.y < 0:
		if dir.x >= abs(dir.y):
			animated_sprite_2d.play(prefix + "_right")
			hitbox.position = Vector2(11.8, 3.8)
			hitbox.scale = Vector2(0.4, 2.5)
		else:
			animated_sprite_2d.play(prefix + "_up")
			hitbox.position = Vector2(0, -7.5)
			hitbox.scale = Vector2(1,1)
	elif dir.x < 0 and dir.y > 0:
		if abs(dir.x) > dir.y:
			animated_sprite_2d.play(prefix + "_left")
			hitbox.position = Vector2(-11.5, 3.8)
			hitbox.scale = Vector2(0.4, 2.5)
		else:
			animated_sprite_2d.play(prefix + "_down")
			hitbox.position = Vector2(0, 15.5)
			hitbox.scale = Vector2(1,1)
	elif dir.x < 0 and dir.y < 0:
		if abs(dir.x) > abs(dir.y):
			animated_sprite_2d.play(prefix + "_left")
			hitbox.position = Vector2(-11.5, 3.8)
			hitbox.scale = Vector2(0.4, 2.5)
		else:
			animated_sprite_2d.play(prefix + "_up")
			hitbox.position = Vector2(0, -7.5)
			hitbox.scale = Vector2(1,1)
		
		
func play_attack_animation(prefix: String, dir: Vector2) -> void:
	if dir.x > 0 and dir.y > 0:
		if dir.x >= dir.y:
			weapon.play(prefix + "_right")
			weapon.show_behind_parent = false
		else:
			weapon.play(prefix + "_down")
			weapon.show_behind_parent = false
	elif dir.x > 0 and dir.y < 0:
		if dir.x >= abs(dir.y):
			weapon.play(prefix + "_right")
			weapon.show_behind_parent = false
		else:
			weapon.play(prefix + "_up")
			weapon.show_behind_parent = true
	elif dir.x < 0 and dir.y > 0:
		if abs(dir.x) > dir.y:
			weapon.play(prefix + "_left")
			weapon.show_behind_parent = false
		else:
			weapon.play(prefix + "_down")
			weapon.show_behind_parent = false
	elif dir.x < 0 and dir.y < 0:
		if abs(dir.x) > abs(dir.y):
			weapon.play(prefix + "_left")
			weapon.show_behind_parent = false
		else:
			weapon.play(prefix + "_up")
			weapon.show_behind_parent = true
			
func attack() -> void:
	weapon_range.monitoring = false
	is_attacking = true
	weapon.visible = true
	play_attack_animation("attack", last_direction)
	hitbox.monitoring = true
	
	
func take_damege(damege: int, attacker_position: Vector2) -> void:
	health -= damege
	if health <= 0:
		die()
	else:
		take_damage_sound.play()
		var knockback_direction = (position - attacker_position).normalized()
		knockback_velocity = knockback_direction * knockback_force
		knockback_timer = knockback_duration
	
	
func die() -> void:
	if not is_alive:
		return
	is_alive = false
	death.visible = true
	death.play()
	animated_sprite_2d.visible = false
	await death.animation_finished
	get_tree().get_first_node_in_group("wave_maneger").call("_on_enemy_died")
	queue_free()
	
	
	
	
	
	
func _on_weapon_animation_finished() -> void:
	if is_attacking:
		is_attacking = false
	weapon.visible = false
	weapon_range.monitoring = true
	
	
func _on_sight_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		target = body
		print("player")
		
		
func _on_sight_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		target = null
	
	
func _on_weapon_range_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		can_attack = true
	
	
func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if is_attacking and body.name == "Player":
			if body.is_invincible:
				return
			body.take_damege(strength, position)
			print("Hit")
			
			

		
		
