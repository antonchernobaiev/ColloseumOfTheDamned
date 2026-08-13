extends Node2D

@onready var panel: Polygon2D = $WavePanel

@onready var label: Label = $WaveLabel




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	panel.polygon = PackedVector2Array([
		Vector2(800, 596),
		Vector2(1148, 596),
		Vector2(1148, 646),
		Vector2(850, 646)
	])
	label.position = Vector2(900, 587)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
