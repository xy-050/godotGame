class_name _15Feb 
extends OpponentBase

# Ability text, ability script, skill_animation_folder

func _init():
	opponent_name = "15Feb"
	normal_attack_damage = 100
	
	skills = {
			"Happy": {
			"description": "Buffs damage by 50% when in 'Sad' state",
			"script_path": "res://scripts/Battle/opponents/opponent_skills/15Feb/Happy.gd",
			"animation_name": "",  
			"ultimate_animation": "",  
			"damage": 0,  # No direct damage
			"cooldown": 2,  # Turns before can use again
			"condition": "hp_below_50",  # When this skill becomes available
			"background": "", #change background to desirable background 
			"field_status": "" #normal, then the 6 other emotions. Different field states give different effects 
		},
		#"Sad": {
			#"description": "Deals 150 damage to all player cards",
			#"script_path": "res://scripts/Battle/opponents/opponent_skills/beyondx/Sad.gd",
			#"animation_name": "beyondx_sad",
			#"damage": 150,
			#"cooldown": 3,
			#"condition": "always"
		#},
		#"Angry": {
			#"description": "Deals 200 damage and heals 50 HP",
			#"script_path": "res://scripts/Battle/opponents/opponent_skills/beyondx/Angry.gd",
			#"animation_name": "beyondx_angry",
			#"ultimate_animation": "beyondx_angry_ultimate",
			#"damage": 200,
			#"healing": 50,
			#"cooldown": 4,
			#"condition": "hp_below_30"
		#}
	
}
	#const normal_attack_animation -> shld be default strike, to make later 
 
