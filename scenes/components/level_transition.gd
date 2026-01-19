@tool
#runscript in editor 
class_name LevelTransition 
extends Area2D

enum SIDE {LEFT, RIGHT, TOP, BOTTOM}

@export_file("*.tscn") var level 
@export var target_transition_area: String = ""
@export_file("*.json") var story_cutscene

@export var spawn_side: SIDE = SIDE.BOTTOM  # Which side to spawn from
@export var spawn_offset: float = 32.0  # Distance in pixels from the area

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	#if we are in the editor, return true 
	if Engine.is_editor_hint(): 
		return 
	
	body_entered.connect(_player_entered)
	
	monitoring = true
	

func _player_entered(body: Node2D) -> void: 
	print("player entered")
	if not body.is_in_group("player"):
		print("player is not in group")
		return
	# Disable monitoring to prevent multiple triggers
	monitoring = false
	
	
	# Get the level name from the path
	var level_name = level.get_file().get_basename()
	print("level_name: " + level_name)
	# Store transition data
	if target_transition_area != "":
		SceneManager.pending_data["spawn_point"] = target_transition_area
		SceneManager.pending_data["spawn_side"] = spawn_side
		SceneManager.pending_data["spawn_offset"] = spawn_offset
	
	# Play transition out effect
	SceneManager.transition_out("fade")  # or "slide"
	
	# Wait for transition to complete
	await SceneManager.transition_out_completed
	
	# Store the target transition area for the next scene
	if target_transition_area != "":
		SceneManager.pending_data["spawn_point"] = target_transition_area
	
	# Change to the new level
	SceneManager.request_world(level_name)
	
	# Wait a frame for the scene to load
	await get_tree().process_frame
	
	# Play transition in effect
	SceneManager.transition_in("fade")  

# Helper function to get spawn position
func get_spawn_position() -> Vector2:
	var shape_rect = collision_shape.shape.get_rect() if collision_shape and collision_shape.shape else Rect2()
	var base_pos = global_position
	
	match spawn_side:
		SIDE.LEFT:
			return base_pos + Vector2(-spawn_offset, 0)
		SIDE.RIGHT:
			return base_pos + Vector2(spawn_offset, 0)
		SIDE.TOP:
			return base_pos + Vector2(0, -spawn_offset)
		SIDE.BOTTOM:
			return base_pos + Vector2(0, spawn_offset)
	
	return base_pos
