class_name Player 
extends CharacterBody2D

var player_direction: Vector2

#player general inventory 
const INVENTORY_DATA: InventoryData = preload("res://scenes/UI/Inventory/player_GeneralInventory.tres")

func queue_notification(_title: String , _message : String) -> void: 
	QuestNotification.add_notification_to_queue(_title, _message)
	
func set_controls_enabled(enabled: bool) -> void:
	set_physics_process(enabled)
	set_process_input(enabled)
