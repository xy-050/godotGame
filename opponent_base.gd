class_name OpponentBase
extends Node

# Override these in child classes
var opponent_name: String = ""
var normal_attack_damage: int = 0
var skills: Dictionary = {}

# Get skill data
func get_skill(skill_name: String) -> Dictionary:
	if skills.has(skill_name):
		return skills[skill_name]
	return {}

# Get all available skills
func get_all_skills() -> Array:
	return skills.keys()

# Check if skill exists
func has_skill(skill_name: String) -> bool:
	return skills.has(skill_name)
