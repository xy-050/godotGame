extends NodeState
class_name Scan

@export var cooldown_after_detection: float = 0.5
@export var scan_duration: float = 3.0  # How long to scan
@export var raycast_count: int = 5  # Number of raycasts
@export var scan_range: float = 200.0  # How far to scan
@export var scan_angle: float = 90.0  # Angle range (degrees)
@export var sweep_speed: float = 180.0  # Degrees per second

var detection_cooldown: float = 0.0 #cooldown to prevent rapid stage switching 
var timer: float = 0.0
var enemy: DBR
var raycasts: Array[RayCast2D] = []
var current_sweep_angle: float = 0.0
var sweep_direction: int = 1  # 1 for forward, -1 for backward

const COLLISION_PLAYER = 1

func _on_enter() -> void:
	timer = 0.0
	enemy = get_parent().get_parent()
	
	# Stop enemy movement while scanning
	enemy.velocity.x = 0
	
	# Get patrol direction to know which way to face
	var patrol_dir = enemy.get_meta("patrol_direction", 1)
	var base_angle = 0 if patrol_dir > 0 else 180
	
	# Start sweep from one side
	current_sweep_angle = base_angle - scan_angle / 2
	sweep_direction = 1
	
	# Create raycasts if they don't exist
	if raycasts.is_empty():
		_create_raycasts()
		#print("Scanning area...")

func _on_physics_process(delta: float) -> void:
	timer += delta
	detection_cooldown -= delta
	
	# Update sweep angle
	current_sweep_angle += sweep_speed * sweep_direction * delta
	
	# Get base direction
	var patrol_dir = enemy.get_meta("patrol_direction", 1)
	var base_angle = 0 if patrol_dir > 0 else 180
	var min_angle = base_angle - scan_angle / 2
	var max_angle = base_angle + scan_angle / 2
	
	# Reverse direction if we hit the limits
	if current_sweep_angle >= max_angle:
		current_sweep_angle = max_angle
		sweep_direction = -1
	elif current_sweep_angle <= min_angle:
		current_sweep_angle = min_angle
		sweep_direction = 1
	
	# Update all raycasts to sweep together
	_update_raycast_positions()
		# CRITICAL: Force physics update BEFORE checking collisions
	for raycast in raycasts:
		raycast.force_raycast_update()  # This updates the raycast state
		
	# Check all raycasts for player
	for raycast in raycasts:
			# Debug: Print raycast position
		#print("Raycast ", raycast, " is colliding: ", raycast.is_colliding())
		
		if raycast.is_colliding():
			var collider = raycast.get_collider()
			
			#print("Raycast hit something: ", collider.name, " | Type: ", collider.get_class())
			#print("Is it PlayerManager? ", collider == PlayerManager)
			#print("PlayerManager name: ", PlayerManager.name if PlayerManager else "NULL")
			
			if collider.is_in_group("player") and detection_cooldown <= 0: 
				#print("Player detected!")
				#transition to a chase/attack state here
				transition.emit("Catch")
				detection_cooldown = cooldown_after_detection
				return
	
	# After scan duration, go back to patrol
	if timer >= scan_duration:
		transition.emit("Patrol")
	


func _on_exit() -> void:
	#print("Scan complete, resuming patrol")
	pass 

func _create_raycasts() -> void:
	# Create multiple raycasts in a fan pattern
	var start_angle = -scan_angle / 2
	var angle_step = scan_angle / (raycast_count - 1)
	
	for i in range(raycast_count):
		var raycast = RayCast2D.new()
		enemy.add_child(raycast)
		
		# Calculate angle for this raycast
		var angle = deg_to_rad(start_angle + (angle_step * i))
		
		# Set raycast direction
		raycast.target_position = Vector2(
		cos(angle) * scan_range,
		sin(angle) * scan_range
		)
		
		raycast.enabled = true
		raycast.collide_with_areas = false
		raycast.collide_with_bodies = true
		raycast.collision_mask = COLLISION_PLAYER
		
		raycasts.append(raycast)

func _update_raycast_positions() -> void:
	# Update all raycasts to follow the current sweep angle
	var angle_spread = 10.0  # Degrees between each raycast for width
	var start_offset = -(raycast_count - 1) * angle_spread / 2
	
	for i in range(raycast_count):
		var offset_angle = start_offset + (i * angle_spread)
		var final_angle = deg_to_rad(current_sweep_angle + offset_angle)
		
		raycasts[i].target_position = Vector2(
			cos(final_angle) * scan_range,
			sin(final_angle) * scan_range
		)
		
