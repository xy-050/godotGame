class_name InventoryUI extends Control 

const INVENTORY_SLOT = preload("res://scenes/UI/Inventory/InventoryItems/inventory_slot.tscn")
var focus_idx: int = 0


@export var data: InventoryData
@onready var close_button: Button = $"../../ClosePage"

func _ready() -> void:
	if close_button:
		close_button.pressed.connect(_on_close_pressed)
	if data:
		data.inventory_updated.connect(_on_inventory_updated)
	clear_inventory()
	data.changed.connect(_on_inventory_changed)
	
	

func clear_inventory() -> void: 
	for c in get_children(): 
		c.queue_free()
	print("inventory cleared")

func _on_inventory_updated() -> void:
	# Only update if the inventory is currently visible
	update_inventory()
	print("inventory updated")

func update_inventory(i: int = 0) -> void: 
	for s in data.slots: 
		var new_slot = INVENTORY_SLOT.instantiate()
		#print("Inventory slot created")
		add_child(new_slot)
		new_slot.slot_data = s
		new_slot.focus_entered.connect(item_focused)
	get_child(0).grab_focus()
		
func item_focused() -> void: 
	for i in get_child_count(): 
		if get_child(i).has_focus(): 
			focus_idx= i
			return 
			
#find inventory and close it 
func _on_close_pressed() -> void:
	PauseMenu.close_inventory()

func _on_inventory_changed(): 
	var i = focus_idx
	clear_inventory()
	update_inventory(i)
	
