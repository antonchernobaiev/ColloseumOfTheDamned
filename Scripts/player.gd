extends CharacterBody2D


signal health_changed(new_health)
signal potion_changed(current_potion)

@export var invincibility_duration:float = 1.0
@export var invincibility_duration_H:float = 0.5
@export var knockback_duration:float = 0.15

const speed = 200.0
const knockback_force:int = 160


var last_direction: Vector2 = Vector2.RIGHT
var is_attacking:bool = false
var strength:int = 20
var health:int = 10
var is_alive:bool = true
var is_invincible:bool = false
var knockback_velocity:Vector2 = Vector2.ZERO
var knockback_timer:float = 0.0
var is_healing:bool = false
var potion:int = 5
var max_potions:int = 5


@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var swing_sword: AudioStreamPlayer2D = $SwingSword
@onready var hitbox: Area2D = $Hitbox
@onready var death: AnimatedSprite2D = $death


func _ready():
	add_to_group("player")
	


func _physics_process(_delta: float) -> void:
	if knockback_timer > 0.0:
		knockback_timer -= _delta
		if knockback_timer <= 0.0:
			knockback_velocity = Vector2.ZERO
	
	
	if is_alive:
		hitbox.monitoring = false
		
		if Input.is_action_just_pressed("attack") and not is_attacking and not is_healing:
			attack()
			
		if Input.is_action_just_pressed("heal") and not is_attacking and not is_healing and potion > 0:
			heal()
			
		if is_attacking or is_healing:
			velocity = Vector2.ZERO
			return
			
		
		
		process_movement()
		process_animation()
		velocity += knockback_velocity
		move_and_slide()
		
	#Movement and Animation
func process_movement() -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector("left", "right", "up", "down")
	
	
	if direction != Vector2.ZERO:
		velocity = direction * speed
		last_direction = direction
	else: 
		velocity = Vector2.ZERO
	
	
func process_animation() -> void:
	if is_attacking or is_healing:
		return
	
	
	if velocity != Vector2.ZERO:
		play_animation("running", last_direction)
	else:
		play_animation("idle", last_direction)



func play_animation(prefix: String, dir: Vector2) -> void:
	if dir.x > 0:
		animated_sprite_2d.play(prefix + "_right")
		hitbox.position = Vector2(23, -1)
		hitbox.scale = Vector2(1, 1)
	elif dir.x < 0:
		animated_sprite_2d.play(prefix + "_left")
		hitbox.position = Vector2(-23, 4)
		hitbox.scale = Vector2(1, 1)
	elif dir.y < 0:
		animated_sprite_2d.play(prefix + "_up")
		hitbox.position = Vector2(-3, -11)
		hitbox.scale = Vector2(1.5, 1)
	elif dir.y > 0:
		animated_sprite_2d.play(prefix + "_down")
		hitbox.position = Vector2(-2, 19)
		hitbox.scale = Vector2(1.5, 1)
	
	
# Attacking
func attack() -> void:
	is_attacking = true
	hitbox.monitoring = true
	swing_sword.play()
	play_animation("attack", last_direction)
	
	
func take_damege(damege: int, attacker_position: Vector2) -> void:
	if is_invincible:
		return
	
	health -= damege
	health_changed.emit(health)
	if health <= 0:
		die()
	else:
		var knockback_direction = (position - attacker_position).normalized()
		knockback_velocity = knockback_direction * knockback_force
		knockback_timer = knockback_duration
		
	start_invincibility()


func die() -> void:
	is_alive = false
	death.visible = true
	death.play()
	animated_sprite_2d.visible = false
	death.play()
	await death.animation_finished
	
	
	var wave_maneger = get_tree().get_first_node_in_group("wave_maneger")
	get_tree().get_first_node_in_group("hud").get_node("GameOverScreen").show_game_over(wave_maneger.wave)
	
	
func start_invincibility():
	is_invincible = true
	flicker_sprite()
	
	await get_tree().create_timer(invincibility_duration).timeout
	is_invincible = false
	animated_sprite_2d.modulate.a = 1.0
	
	
func flicker_sprite():
	var flicker_tween = create_tween()
	flicker_tween.set_loops(int(invincibility_duration / 0.1))
	flicker_tween.tween_property(animated_sprite_2d, "modulate:a", 0.3, 0.05)
	flicker_tween.tween_property(animated_sprite_2d, "modulate:a", 1.0, 0.05)
	
func heal():
	if potion <= 0:
		return
		
	if health < 10:
		potion -= 1
		potion_changed.emit(potion)
		is_invincible = true
		is_healing = true
		if health == 9:
			health += 1
		if health < 9:
			health += 2
		health_changed.emit(health)
		play_animation("heal", last_direction)
		
		


func _on_animated_sprite_2d_animation_finished() -> void:
	if is_attacking:
		is_attacking = false
	if is_healing:
		is_healing = false
		await get_tree().create_timer(invincibility_duration_H).timeout
		is_invincible = false
	
	
func _on_hitbox_body_entered(body: Node2D) -> void:
	if is_attacking and body.is_in_group("enemies"):
		body.take_damege(strength, position)
		
