extends Control

signal choice_selected 

#Preload the player choice scene once then instantiate diff versions of it 
const ChoiceButtonScene = preload("res://scenes/Story/button.tscn")

@onready var dialog_line = %DialogLine
@onready var speaker_name = %SpeakerName
@onready var choice_list = %ChoiceList

const ANIMATION_SPEED: int = 30
var animate_text: bool = false
var current_visible_characters : int =0

func _ready() -> void:
	#reset display 
	#hide choice list first 
	choice_list.hide()
	dialog_line.text= ""
	speaker_name.text = ""

func _process(delta) :
	if animate_text: 
		if dialog_line.visible_ratio < 1: 
			dialog_line.visible_ratio += (1.0/dialog_line.text.length()) * (ANIMATION_SPEED * delta)
			current_visible_characters = dialog_line.visible_characters
	else: 
		animate_text = false 

func display_choices(choices: Array): 
	#Clear any existing choices first
	for child in choice_list.get_children(): 
		child.queue_free()
	
	#create a new button for each choice 
	for choice in choices:
		var choice_button = ChoiceButtonScene.instantiate()
		choice_button.text = choice["text"]
		#attach signal to button
		choice_button.pressed.connect(_on_choice_button_pressed.bind(choice["goto"]))
		#Add button to choices container 
		choice_list.add_child(choice_button)
	
	#show choice list 
	choice_list.show()

func change_line(character_name: Character.Name, line: String):
	speaker_name.text = Character.CHARACTER_DETAILS[character_name]["name"]
	current_visible_characters = 0
	dialog_line.text = line 
	dialog_line.visible_characters = 0
	animate_text = true 

func skip_text_animation(): 
	dialog_line.visible_ratio = 1
	animate_text = false 

func _on_choice_button_pressed(anchor: String): 
	choice_selected.emit(anchor)
	choice_list.hide()
