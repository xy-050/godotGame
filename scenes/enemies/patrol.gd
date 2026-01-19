extends NodeState

@export var move_speed: float = 100.0
@export var min_distance: float = 10.0  # Minimum distance to travel
@export var max_distance: float = 2000  # Maximum distance to travel
@export var detection_range: float = 800.0

@onready var detection_raycast = $"../../RayCast2D"

var timer: float = 0.0
var distance_to_travel: float = 0.0
var distance_traveled: float = 0.0
var direction: int = 1 
var enemy: DBR

const COLLISION_MASK_PLAYER = 1 << 0 

func _on_enter() -> void:
	timer = 0.0
	enemy = get_parent().get_parent()  # Get the enemy node
	distance_to_travel = randf_range(min_distance, max_distance)
	distance_traveled = 0.0
	
	# Randomly pick direction
	direction = 1 if randf() > 0.5 else -1
	
	detection_raycast.collision_mask = 3
	detection_raycast.enabled = true
	detection_raycast.exclude_parent = true
	detection_raycast.scale = Vector2.ONE
	
	# Player + World only
	detection_raycast.collision_mask = (1 << 0) | (1 << 1)
	detection_raycast.collide_with_areas = true
	
	#print("Patrol started - RayCast collision_mask set to: ", detection_raycast.collision_mask)


func _on_physics_process(delta: float) -> void:
	# Find player and check distance
	var player = get_tree().get_first_node_in_group("player")
	
	if player:
		var distance_to_player = enemy.global_position.distance_to(player.global_position)
		
		# DEBUG: Print every 60 frames
		if Engine.get_physics_frames() % 60 == 0:
			#print("Distance to player: ", distance_to_player, " | In range: ", distance_to_player <= detection_range)
			
			# Test if raycast can hit ANYTHING at all
			detection_raycast.target_position = Vector2(1000, 0)  # Point right
			detection_raycast.force_raycast_update()
			#print("  Test right: ", detection_raycast.is_colliding())
			
			detection_raycast.target_position = Vector2(-1000, 0)  # Point left
			detection_raycast.force_raycast_update()
			#print("  Test left: ", detection_raycast.is_colliding())
			
			detection_raycast.target_position = Vector2(0, 1000)  # Point down
			detection_raycast.force_raycast_update()
			#print("  Test down: ", detection_raycast.is_colliding())
		
		# Check if player is in range
		if distance_to_player <= detection_range:
			# Point raycast toward player
			
			var local_target = detection_raycast.to_local(player.global_position)
			detection_raycast.target_position = local_target.normalized() * detection_range
			detection_raycast.force_raycast_update()
			
			## DEBUG: Show what raycast is doing
			#if Engine.get_physics_frames() % 60 == 0:
				#print("  Raycast firing! Target: ", detection_raycast.target_position)
				#print("  Is colliding: ", detection_raycast.is_colliding())
				#
				#if detection_raycast.is_colliding():
					#print("  Hit: ", detection_raycast.get_collider().name)
			
			# Check if we have line of sight
			if detection_raycast.is_colliding():
				var collider = detection_raycast.get_collider()
				#print("Raycast hit: ", collider.name)
				
				if collider.is_in_group("player"):
					print("PLAYER DETECTED! Transitioning to Catch")
					enemy.set_meta("patrol_direction", direction)
					transition.emit("Catch")
					return
		
		
	
	# Move the enemy right
	enemy.velocity.x = move_speed * direction 
	enemy.velocity.y = 0
	enemy.move_and_slide()
	
	
	# Track how far we've moved
	distance_traveled += abs(enemy.velocity.x * delta)
	
	# After duration, switch to moving left
	if distance_traveled >= distance_to_travel:
		#print("transitioning to scan")
		transition.emit("Scan")
		
	#print("Changing direction, new distance: ", distance_to_travel)

## Pick new random values
		#distance_to_travel = randf_range(min_distance, max_distance)
		#distance_traveled = 0.0
		#direction *= -1
