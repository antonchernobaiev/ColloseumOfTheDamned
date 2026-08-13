extends HBoxContainer

@export var heart_full: AtlasTexture
@export var heart_half: AtlasTexture
@export var heart_empty: AtlasTexture

@export var max_health: int = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var player = get_tree().get_first_node_in_group("player")
	player.health_changed.connect(update_hearts)
	update_hearts(player.health)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
	
func update_hearts(current_health: int) -> void:
	for child in get_children():
		child.queue_free()
	
	var full_hearts = current_health / 2
	var has_half = current_health % 2 == 1
	var total_hearts = max_health / 2
	
	for i in range(total_hearts):
		var heart: TextureRect = TextureRect.new()
		if i < full_hearts:
			heart.texture = heart_full
		elif i == full_hearts and has_half:
			heart.texture = heart_half
		else:
			heart.texture = heart_empty
		add_child(heart)
	
