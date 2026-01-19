class_name OpponentSkill extends Resource 

@export var skill_name: String = ""
@export var description: String = ""
@export var skill_script_path: String = ""  # Path to the skill script
@export var animation_name: String = ""  # Name in AnimationPlayer/AnimatedSprite2D
@export var cooldown: int = 0
@export_range(0.0, 10.0) var weight: float = 1.0  # For chance-based selection


# Method to load the actual script
func get_skill_script() -> Node:
	if skill_script_path != "":
		var script = load(skill_script_path)
		return script.new()
	return null 
