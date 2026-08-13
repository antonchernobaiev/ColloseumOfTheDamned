extends Control


@onready var wave_label: Label = $WaveReachedLabel
@onready var return_button: Button = $ReturnButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	return_button.pressed.connect(_on_return_pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func show_game_over(wave_reached: int) -> void:
	wave_label.text = "You reached wave " + str(wave_reached)
	visible = true
	
func _on_return_pressed() -> void:
	get_tree().change_scene_to_file("uid://wmlya17s675r")
