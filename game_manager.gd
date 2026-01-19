extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE
