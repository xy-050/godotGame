extends CanvasLayer

#Buttons 
@onready var inventory_button: Button = $Control/Buttons/InventoryButton
@onready var system_button: Button = $Control/Buttons/SystemButton
@onready var quest_button: Button = $Control/Buttons/QuestButton
@onready var characterDB_button: Button =  $Control/Buttons/CharacterDBButton
@onready var cardDB_button: Button = $Control/Buttons/CardDBButton


@onready var bg_music: AudioStreamPlayer = $Control/bgMusic
@onready var music_file_path = preload("res://assets/Music/Start Menu.mp3")

#References: 
@onready var inventory_ui: Control = $Control/GeneralInventory
@onready var item_description: Label = $Control/ItemDescription
@onready var system_ui: Control = $Control/System
@onready var quest_ui: Control = $Control/Quests
@onready var characterDB_ui: Control = $Control/CharacterDB
@onready var cardDB_ui: Control = $Control/CardDB
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_paused = false
var music_playing = false 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide_pause_menu()
	
	inventory_button.pressed.connect(_on_inventory_pressed)
	system_button.pressed.connect(_on_system_pressed)
	quest_button.pressed.connect(_on_quest_pressed)
	characterDB_button.pressed.connect(_on_characterDB_pressed)
	cardDB_button.pressed.connect(_on_cardDB_pressed)
	
	
	
	# Make sure all subsequent UI is hidden and transparent initially
	system_ui.visible = false
	quest_ui.visible = false
	characterDB_ui.visible = false
	cardDB_ui.visible = false 
	
	if inventory_ui:
		inventory_ui.visible = false
		item_description.visible = false
		
	
	show_buttons()
	
	
	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if is_paused == false:
			show_pause_menu() 
		else: 
			hide_pause_menu() 
		get_viewport().set_input_as_handled()

func show_pause_menu() -> void: 
	bg_music.stream = music_file_path
	bg_music.play()
	get_tree().paused = true 
	visible = true 
	is_paused = true 
	
	music_playing = true 
	
func hide_pause_menu() -> void: 
	if music_playing:
		bg_music.stop()
		
	get_tree().paused = false 
	visible = false 
	is_paused = false 
	
	#close any existing UI 
	close_inventory()
	close_characters()
	close_cards()
	close_quest()
	close_system()
	


func _on_inventory_pressed() -> void: 
	if not inventory_ui:
		return
	#hide_buttons()
	# Show  inventory in
	inventory_ui.visible = true
	hide_buttons()

func close_inventory() -> void:
	if not inventory_ui:
		return
	
	inventory_ui.visible = false
	show_buttons()

func _on_audio_stream_player_finished() -> void:
	bg_music.play() # Replace with function body.


func update_item_desc(new_text: String) -> void: 
	item_description.text = new_text
	
func _on_system_pressed() -> void: 
	if not system_ui: 
		return
	animation_player.play("transition_to_systemMenu")
	system_ui.visible = true
	hide_buttons()

func close_system() -> void: 
	if not system_ui: 
		return
	animation_player.play_backwards("transition_to_systemMenu")
	system_ui.visible = false
	show_buttons()

func close_characters(): 
	if not characterDB_ui: 
		return
	characterDB_ui.visible = false 
	show_buttons()

func close_quest() -> void: 
	if not quest_ui: 
		return 
	quest_ui.visible = false
	show_buttons()

func close_cards() -> void: 
	if not cardDB_ui: 
		return 
	cardDB_ui.visible = false
	show_buttons()

	
func _on_quest_pressed() -> void: 
	if not quest_ui: 
		return 
	quest_ui.visible = true
	hide_buttons()
 
	
func _on_characterDB_pressed() -> void: 
	if not characterDB_ui: 
		return
	characterDB_ui.visible = true 
	hide_buttons()

func _on_cardDB_pressed() -> void: 
	if not cardDB_ui:
		return 
	cardDB_ui.visible = true 
	hide_buttons()

func hide_buttons(): 
	inventory_button.visible = false
	system_button.visible = false
	quest_button.visible = false
	characterDB_button.visible = false
	cardDB_button.visible = false
	

func show_buttons(): 
	inventory_button.visible = true
	system_button.visible = true
	quest_button.visible = true
	characterDB_button.visible = true
	cardDB_button.visible = true
