class_name SaveDataComponent
extends Node2D

@onready var parent_node: Node2D = get_parent() as Node2D

@export var save_data_resource: Resource 

func _ready() -> void:
	add_to_group("save_data_component")
