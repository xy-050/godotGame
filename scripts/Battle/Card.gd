extends Node2D 

signal hovered 
signal hovered_off 

var card_slot_card_is_in ##card_slot_is_in
var starting_position 
var card_type #memory or event 
var card_owner
var hp 
var trust_cost
var attack 
var defeated = false 
var ability_script 
var card_name 
var damage_multiplier: float = 1.0


func _ready() -> void:
	await get_tree().process_frame
	#All cards must be a child of CardManager or this will error 
	#print(get_parent())
	get_parent().connect_card_signals(self) #call connect function in parent 
	print("Card: ")
	print(scale)
	
	
func _on_area_2d_mouse_entered() -> void:
	#print("hovered") 
	emit_signal("hovered", self)


func _on_area_2d_mouse_exited() -> void:
	#print("hovered off") 
	emit_signal("hovered_off", self)
