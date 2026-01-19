###TODO: 
## show_character isnt working 
## Load original world map scene after completing a book 
extends Node2D

@onready var bg_music = %backgroundMusic
@onready var background = %Background 
@onready var character = %CharacterSprite
@onready var dialog_ui = %DialogUI

var transition_effect: String = "fade"
#const DIALOG_FILE = "res://resources/story/main_story/mainStory.json"
var dialog_file: String = ""
var dialog_index : int = 0
var dialog_lines: Array = []
var _externally_initialized: bool = false 
var can_process_input: bool = false

signal battle_requested(opponent_name, opponent_background, transition_effect)
signal return_to_world_requested(level_name: String)
signal quest_accepted(title: String, message: String)


func _ready(): 
	#connect signals 
	dialog_ui.choice_selected.connect(_on_choice_selected)
	#fade out the scene 
	if not SceneManager.transition_out_completed.is_connected(_on_transition_out_completed):
		SceneManager.transition_out_completed.connect(_on_transition_out_completed)
	if not SceneManager.transition_in_completed.is_connected(_on_transition_in_completed):
		SceneManager.transition_in_completed.connect(_on_transition_in_completed)
	battle_requested.connect(SceneManager.request_battle)
	return_to_world_requested.connect(SceneManager.request_world)
	quest_accepted.connect(SceneManager._on_story_quest_accepted)
	SceneManager.register_story_scene(self)
	
	# Check for pending data FIRST
	if SceneManager.pending_data.has("dialog_file"):
		print("Loading from pending_data: ", SceneManager.pending_data.dialog_file)
		var file_to_load = SceneManager.pending_data.dialog_file
		SceneManager.pending_data.clear()
		initialize(file_to_load, 0)
		start_dialog()
	#elif not _externally_initialized:
		#print("Loading default dialog file")
		#initialize(DIALOG_FILE, 0)
		#start_dialog()

func _exit_tree():
	# Clean up connections when scene is being removed
	if SceneManager.transition_out_completed.is_connected(_on_transition_out_completed):
		SceneManager.transition_out_completed.disconnect(_on_transition_out_completed)
	if SceneManager.transition_in_completed.is_connected(_on_transition_in_completed):
		SceneManager.transition_in_completed.disconnect(_on_transition_in_completed)
	if battle_requested.is_connected(SceneManager.request_battle):
		battle_requested.disconnect(SceneManager.request_battle)
	if return_to_world_requested.is_connected(SceneManager.request_world):
		return_to_world_requested.disconnect(SceneManager.request_world)

func initialize(file_path: String, start_index := 0):
	print("Initialize called with: ", file_path)
	_externally_initialized = true
	dialog_file = file_path
	dialog_index = 0  # Always start at 0

func start_dialog():
	print("start_dialog called")
	print("Loading dialog from: ", dialog_file)
	dialog_lines = load_dialog(dialog_file)
	print("Loaded ", dialog_lines.size(), " dialog lines")
	dialog_index = 0  # Ensure we start at the beginning
	print("Starting at index: ", dialog_index)
	SceneManager.transition_in()

func _input(event):
	if not can_process_input:  # Block input until ready
		return
	if dialog_lines.is_empty():
		return
	if dialog_index >= dialog_lines.size():
		return
	var line = dialog_lines[dialog_index]
	var has_choices = line.has("choices")
	if event.is_action_pressed("next_line") and not has_choices:
		if dialog_ui.animate_text: 
			dialog_ui.skip_text_animation()
		else: 
			if dialog_index < len(dialog_lines) - 1: 
				dialog_index += 1 
				process_current_line()


func process_current_line(): 
	#print("========== PROCESS_CURRENT_LINE CALLED ==========")
	#print("dialog_index: ", dialog_index)
	#print("dialog_lines.size(): ", dialog_lines.size())
	if dialog_index >= dialog_lines.size() or dialog_index < 0: 
		printerr("dialog index out of bounds")
		return 
	#Extract current line
	var line = dialog_lines[dialog_index]
	
	#Check if this is the end of our scene 
	if line.has("next_scene"): 
		var next_scene = line["next_scene"]
		dialog_file = "res://resources/story/" + next_scene + ".json" if !next_scene.is_empty() else ""
		#automatically set transition to fade-- do not need to specify 
		transition_effect = line.get("transition", "fade")
		SceneManager.transition_out(transition_effect)
		return 
	
	#return to open world
	if line.has("return_to_world"):
		var return_to_world = line["return_to_world"]
		return_to_world_requested.emit(return_to_world)
		return 
	
	#go into battle if command is triggered 
	if line.has("start_battle"): 
		var begin_battle = line["start_battle"]
		var battle_array = []
		battle_array = begin_battle.split(",", false ,2) #split the line into 2 
		var opponent_name = battle_array[0]
		var opponent_background = battle_array[1]
		var battle_scene = "res://scenes/Battle/battle.tscn" if !begin_battle.is_empty() else "" 
		transition_effect = line.get("transition", "fade")
		battle_requested.emit(
			opponent_name, opponent_background, transition_effect
		)
		return  
		
	
	#begin quest: 
	if line.has("begin_quest"): 
		print("DEBUG: Found begin_quest, emitting signal")
		var quest_info = line["begin_quest"]  # Get the value
		var parts = quest_info.split(",")
		var title = parts[0].strip_edges()
		var message = parts[1].strip_edges()
		quest_accepted.emit(title, message)
		
		print("Listeners:", quest_accepted.get_connections())
		print("DEBUG: Signal emitted")

	#Check if this is a location 
	if line.has("location"): 
		background.visible = true
		
		if line["location"] == "": 
			background.visible = false
			
		#change bg 
		var background_file = "res://assets/Backgrounds/" + line["location"] + ".png"
		background.texture = load(background_file)
		print(background_file)
		#change music 
		var music_file = "res://assets/Music/" + line["music"] + ".mp3"
		bg_music.stream = load(music_file)
		#print(music_file)
		bg_music.play()
		
		#proceed to next line w/o waiting for user input 
		dialog_index += 1 #skip over loc line
		process_current_line()
		return
	
	#Check if this is a goto command 
	if line.has("goto"): 
		dialog_index = get_anchor_position(line["goto"])
		process_current_line()
		return 
	
	#Check if this is just an anchor declaration (not displayable content)
	if line.has("anchor"):
		dialog_index += 1 
		process_current_line()
		return 
	
	#update character sprite accordingly, default to speaker command if show_character is not present 
	if line.has("show_character"): 
		print("cutscene begin")
		var character_name = Character.get_enum_from_string(line["show_character"])
		character.change_character(character_name, line.get("expression", ""))
		print("speaker:", character_name, "expression:", line.get("expression", ""))
		
	elif line.has("speaker"): 
		print("show person")
		var character_name = Character.get_enum_from_string(line["speaker"])
		character.change_character(character_name, line.get("expression", ""))
	
		#Choices is not working for some reason 
		#implement Beyond Choice
	if line.has("choices"): 
		#Display choices 
		dialog_ui.display_choices(line["choices"]) 
	elif line.has("text"): 
	#reading the line of dialog
		var character_name = Character.get_enum_from_string(line["speaker"])
		#character.change_character(character_name, line.get("expression", ""))
		dialog_ui.change_line(character_name, line["text"])
	else: 
		#no choice or line of dialog 
		dialog_index += 1 
		process_current_line()
	
	#hide & show cutscenes
	if line.has("show_cutscene"): 
		character.hide()
		#print("character hidden")
	elif line.has("hide_cutscene"): 
		character.show()
		#print("character shown")
		return 
	

func get_anchor_position(anchor: String):
	#Find the anchor entry with matching name 
	for i in range(dialog_lines.size()): 
		if dialog_lines[i].has("anchor") and dialog_lines[i]["anchor"] == anchor: 
			return i 
	#anchor not found throughout script 
	printerr("Error: could not find anchor '" + anchor + "'")
	return null 

func load_dialog(file_path): 
	#check if file exists 
	if not FileAccess.file_exists(file_path): 
		printerr("Error: File does not exist: ", file_path)
		return null 
		
	#open & read file 
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null: 
		printerr("Error: Failed to open the file: ", file_path)
		return null 
	
	var content = file.get_as_text()
	var json_content = JSON.parse_string(content)
	
	#check if parsing was successful 
	if json_content == null: 
		printerr("Error: Failed to parse JSON from file: ", file_path)
		return null 
	return json_content 
	

func process_name(character_name: String) -> String:
	var result = ""
	for i in character_name.strip_edges():
		if i != " " and i != "\t" and i != "\n" and i != "\r":
			result += i
	return result

#character idles not done 
func _on_choice_selected(anchor: String):
	dialog_index = get_anchor_position(anchor)
	process_current_line()


func _on_audio_stream_player_finished() -> void:
	bg_music.play() # Replace with function body.

func _on_transition_out_completed():
	#load new dialog
	if !dialog_file.is_empty(): 
		dialog_lines = load_dialog(dialog_file)
		dialog_index = 0
		var first_line = dialog_lines[dialog_index]
		if first_line.has("location"):
			background.texture = load("res://assets/Backgrounds/" + first_line["location"] + ".png")
			
			#change music 
			var music_file = "res://assets/Music/" + first_line["music"] + ".mp3"
			bg_music.stream = load(music_file)
			bg_music.play()
			
			dialog_index += 1
			#works up until this point 
		SceneManager.transition_in(transition_effect)
		
	else: #link back to world map 
		print("End")

func _on_transition_in_completed():
	#print("========== on_transition_in completed ==========")
	#print("Current dialog_index: ", dialog_index)
	#print("Total dialog_lines: ", dialog_lines.size())
	
	if dialog_lines.is_empty():
		printerr("ERROR: dialog_lines is EMPTY!")
		return
	
	if dialog_index >= dialog_lines.size():
		printerr("ERROR: dialog_index out of bounds!")
		return
	
	can_process_input = true
	#print("About to call process_current_line...")
	#start processing dialog 
	process_current_line()
	#print("========== process_current_line finished ==========")
