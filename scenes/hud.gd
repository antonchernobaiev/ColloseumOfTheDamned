extends CanvasLayer

@onready var wave_label: Label = $WaveDisplay/WaveLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func update_wave(wave_number) -> void:
	wave_label.text = "Wave " + str(wave_number)
