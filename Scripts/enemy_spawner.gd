extends Node2D

@onready var main = get_node("/root/Main")
@export var wave_display: Node

var enemy_scene  := preload("res://scenes/skeleton.tscn")
var spawn_points := []
var current_wave_fin: bool = true
var wave:int = 1
var enemies_remaining: int = 0 


func _ready() -> void:
	add_to_group("wave_maneger")
	for i in get_children():
		if i is Marker2D:
			spawn_points.append(i)
	call_deferred("start_wave")
	
	
func start_wave():
	wave_display.update_wave(wave)
	var base_count = 1
	var enemy_count = base_count * wave
	enemies_remaining = enemy_count
	
	for i in range(enemy_count):
		var enemy = enemy_scene.instantiate()
		var point = spawn_points[randi() % spawn_points.size()]
		add_child(enemy)
		enemy.global_position = point.global_position
		
		
func _on_enemy_died() -> void:
	enemies_remaining -= 1
	if enemies_remaining <= 0:
		wave += 1
		await get_tree().create_timer(2.0).timeout
		start_wave()
		
