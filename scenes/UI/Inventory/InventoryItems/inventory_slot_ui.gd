class_name InventorySlotUI extends TextureButton

@onready var quantity: Label = $Quantity
@onready var item: TextureRect = $TextureRect

var slot_data: SlotData : set = set_slot_data

func _ready() -> void: 
	item.texture = null
	quantity.text = ""
	
	# Connect focus signals
	focus_entered.connect(item_focused)
	focus_exited.connect(item_unfocused)
	
	# Make sure focus mode is enabled
	focus_mode = Control.FOCUS_ALL

func set_slot_data(value: SlotData) -> void:
	slot_data = value 
	if slot_data == null: 
		return 
	
	# Add null checks here!
	if slot_data == null or slot_data.item_data == null: 
		item.texture = null
		quantity.text = ""
		print("missing data")
		return 
	
	item.texture = slot_data.item_data.texture
	quantity.text = str(slot_data.quantity)
	

func item_focused() -> void: 
	if slot_data == null or slot_data.item_data == null:
		return
	PauseMenu.update_item_desc(slot_data.item_data.item_description)
	pass 

func item_unfocused() -> void: 
	pass 
