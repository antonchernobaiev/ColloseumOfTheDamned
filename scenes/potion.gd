extends HBoxContainer

@export var _potion: AtlasTexture

var max_potions:int = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var player = get_tree().get_first_node_in_group("player")
	player.potion_changed.connect(update_potion)
	update_potion(player.potion)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func update_potion(amount_of_potions: int) -> void:
	for child in get_children():
		child.queue_free()
	
	var has_potions = amount_of_potions
	
	for i in range(has_potions):
		var potion: TextureRect = TextureRect.new()
		potion.texture = _potion
		
		potion.rotation_degrees = 45
		add_child(potion)
		
	
