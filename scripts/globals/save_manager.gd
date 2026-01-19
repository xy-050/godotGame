extends Node

const SAVE_PATH := "user://save_game.json"

signal game_saved 
signal game_loaded 

#Things that i want saved in the game: 
# trust levels 
# player inventory -> cardDB 
# quests = [] 
# scene path 
# where the player is at (location in terms of x & y)
# level player is on 
var current_save: Dictionary = {
	#Core player state 
	"current_trust" : 1, 
	"player_card_database": {}, 
	
	"quests": [
		#{title = "not found", is_complete = false, completed_steps = ['']}
	], 
	
	#World state 
	"overworld_scene_path": "",
	"player_position": {"pos_x": 0, "pos_y": 0},  # x & y location
	#player levels
	"current_level": 1,
	#save_timestamp 
	"save_timestamp" : "" 
}

func save_game() -> void:
	
	# Gather current state
	current_save["current_trust"] = TrustManager.get_trust()
	
	#Only save if player is in Overworld(not in battle) 
	var current_scene = get_tree().current_scene
	if is_in_overworld():
		update_player_data()
		current_save["overworld_scene_path"] = current_scene.scene_file_path
	else:
		print("Currently in battle, using last overworld position")
	
	
	#current_save["player_inventory"] = CardDatabase.get_inventory() 
	
	#Save inventory 
	update_item_data()
	
	#Save quest data 
	update_quest_data()
	
	current_save["save_timestamp"] = Time.get_datetime_string_from_system()
	
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	
	if file == null:
		push_error("Failed to open save file")
		return
	
	var save_json = JSON.stringify(current_save)
	if save_json == null:
		push_error("Failed to convert save data to JSON")
		return
	file.store_line(save_json)
	game_saved.emit()
	file.close()
	print("Game saved successfully!")
		


func load_game() -> bool:
	print("load game")
	
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found")
		return false
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_line()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			current_save = json.data
			
			# Restore state to managers
			TrustManager.current_trust = current_save["current_trust"]
			
			#CardDatabase.load_inventory(current_save["player_card_database"])
			
			#Restore the inventory data 
			PlayerManager.INVENTORY_DATA.parse_save_data(current_save.items)
			
			#Restore quests 
			QuestManager.current_quests = current_save.quests
			
			restore_player_position()
			
			
			
			print("Game loaded successfully!")
			game_loaded.emit()
			return true
		else:
			push_error("Failed to parse save file JSON")
			return false
	else:
		push_error("Failed to open save file for reading")
		return false

func update_player_data() -> void: 
	current_save["player_position"]["pos_x"] = PlayerManager.global_position.x
	current_save["player_position"]["pos_y"] = PlayerManager.global_position.y
	print("Player position saved: ", current_save["player_position"])

func restore_player_position() -> void: 
	# sceneManager loads scene 
	if current_save["overworld_scene_path"] != "":
		SceneManager.request_world(["overworld_scene_path"])
	
	#load the player's precise position in this scene
	PlayerManager.global_position.x = current_save["player_position"]["pos_x"]
	PlayerManager.global_position.y = current_save["player_position"]["pos_y"]

func is_in_overworld() -> bool:
	var current_scene_path = get_tree().current_scene.scene_file_path
	# Adjust this to match your actual overworld scene name
	return "overworld" in current_scene_path.to_lower() 

func save_game_with_transition() -> void:
	SceneManager.transition_out("fade")
	await SceneManager.transition_out_completed
	save_game()
	await get_tree().create_timer(0.3).timeout  # Brief pause to show save happened
	SceneManager.transition_in("fade")

func update_item_data() -> void: 
	current_save.items = PlayerManager.INVENTORY_DATA.get_save_data()

func update_quest_data() -> void: 
	current_save.quests = QuestManager.current_quests
