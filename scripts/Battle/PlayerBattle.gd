###TODO: IMPLEMENT LEFT RIGHT N BEHIND IF HAVE TIME 
#instantiate random chance of hand spawning in all 4 directions. Need to click to prevent 
extends Node2D

@onready var camera = $Camera2D
@onready var flip_button = $FlipUpButton

var cameras_up = false
var camera_down_position := Vector2(962, 602) 
var camera_up_position := Vector2(955, -603)  
var transition_speed = 8.0

func _ready():
	# Connect the button signal
	flip_button.pressed.connect(_on_flip_up_button_pressed)
	
	# Set initial camera position
	camera.position = camera_down_position

func _process(delta):
	# Smoothly interpolate camera position
	if cameras_up:
		camera.position = camera.position.lerp(camera_up_position, transition_speed * delta)
		flip_button.position.y = -300
		
	else:
		camera.position = camera.position.lerp(camera_down_position, transition_speed * delta)
		flip_button.position.y = 100
		

func _on_flip_up_button_pressed() -> void:
	cameras_up = !cameras_up
	
	# Optional: Play sound effect
	# $FlipSound.play()
	
	# Optional: Disable button during transition
	# flip_button.disabled = true
	# await get_tree().create_timer(0.3).timeout
	# flip_button.disabled = false





#extends Node2D
#
#@onready var cam := $Camera2D
#
## The camera positions
#var normal_pos := Vector2(0, 0)
#var look_up_pos := Vector2(955, -603)
#
## How far the mouse must look up
#var look_amount := 0.0
#var look_sensitivity := 0.15
#var look_decay := 6.0
#
#var flip_up_threshold := 0.6    # Must reach this to flip up
#var flip_down_threshold := 0.3  # Must fall below this to flip down
#
#var is_flipped := false
#var flip_speed := 6.0
#var target
#
#func _ready():
	#Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	#normal_pos = cam.position  # Save your default position
#
#func _input(event):
	#if event is InputEventMouseMotion:
		#look_amount -= event.relative.y * look_sensitivity
		#look_amount = clampf(look_amount, -1.0, 1.0)
#
#func _process(delta):
	## Smoothly relax the look amount back to 0
	#look_amount = lerp(look_amount, 0.0, delta * look_decay)
	#
	## Use different thresholds for flipping up vs down
	#if look_amount > flip_up_threshold and not is_flipped:
		#is_flipped = true
	#elif look_amount < flip_down_threshold and is_flipped:
		#is_flipped = false
	#
	#if is_flipped:
		#target = look_up_pos
	#else: 
		#target = normal_pos
	#
	#cam.position = cam.position.lerp(target, delta * flip_speed)
