extends Camera2D

@export var background: Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var texture_size = background.texture.get_size()  
	var world_size = texture_size * background.scale
	var world_rect = Rect2 (background.global_position - (world_size * background.pivot_offset), world_size)
	limit_right = world_rect.position.x
	limit_left = world_rect.position.y 
