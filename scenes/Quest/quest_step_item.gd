class_name QuestStepItem extends Control

@onready var label: Label = $Label
@onready var sprite_2d: Sprite2D = $Sprite2D

const checked = preload("res://assets/ui/checked.png")
const unchecked = preload("res://assets/ui/unchecked.png")

func initialize(step : String, is_complete : bool) -> void: 
	label.text = step 
	if is_complete: 
		sprite_2d.texture = checked
	else: 
		sprite_2d.texture = unchecked
	
