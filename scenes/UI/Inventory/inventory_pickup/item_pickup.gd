@tool
class_name ItemPickup extends Node2D

@export var item_data: ItemData: set = _set_item_data 

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var interactable_component: InteractableComponent = $InteractableComponent
@onready var interactable_label_component: Control = $InteractableLabelComponent
@onready var item: Sprite2D = $Item

var is_in_range = false 

func _ready() -> void:
	_update_texture()
	
	if Engine.is_editor_hint(): 
		return 
	
	interactable_component.interactable_activated.connect(on_interactable_activated) # Replace with function body.
	interactable_component.interactable_deactivated.connect(on_interactable_deactivated)
	interactable_label_component.hide() #hide the component by default
	

#func item_picked_up() -> void:
	#area_2d.body_entered.disconnect(_on_body_entered)

func _update_texture() -> void: 
	if item_data and item:
		item.texture = item_data.texture
  

func _set_item_data(value: ItemData) -> void: 
	item_data = value 
	_update_texture()
	 

func on_interactable_activated() -> void: 
	is_in_range = true
	interactable_label_component.show()

func on_interactable_deactivated() -> void: 
	is_in_range = false
	interactable_label_component.hide()
	
#upon pressing "F"
#should change show_dialog to something else some other time 
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("show_dialog"):
		if item_data and is_in_range:
			pick_up_item() 
			

func pick_up_item(): 
	# Add to player's inventory
	var TryAdd = PlayerManager.INVENTORY_DATA.add_item(item_data)
	
	if !TryAdd:
		print("failed to pick up item")
		return
	
	# Play sound
	audio_stream_player_2d.play()
	
	visible = false 
	
	#await audio to finish first 
	await audio_stream_player_2d.finished
	
	# Hide sprite/remove from world
	queue_free()
	print("item is picked up")
