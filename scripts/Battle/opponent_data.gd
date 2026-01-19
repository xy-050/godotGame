@tool 
class_name OpponentData extends Resource

@export var opponent_name: String = ""
@export var hp: int = 1000

@export var opponent_script_path: String = "" 

#opponent has voice lines at different hps 
#@export var opponent_dialog_file_path: 
@export var patience_timer: float = 0

@export var sprite_path: String = ""
@export var music_name: String = ""

#able to see player's cards
@export var look_ahead_depth: float = 0.0

#conditional -> if hp drops below a certain amt / if player max combo is set to deal x amt of damage. 
#chance_based -> random chance of using skill 
enum Type {CONDITIONAL, CHANCE_BASED}

@export var type: Type 
@export_range (0.0, 10.0) var chance_weight := 0.0 
@export var has_minions: bool = false 


# Load the opponent script instance
func get_opponent_instance() -> OpponentBase:
	if opponent_script_path != "":
		var OpponentScript = load(opponent_script_path)
		return OpponentScript.new()
	return null
