extends Node2D

#signals 
#To know when the scene is changing 
signal transition_out_completed 
signal transition_in_completed 
signal quest_requested 


#black ColorRect for transition animations
var transition_layer: CanvasLayer
var transition_rect: ColorRect
var transition_time: float = 0.5 
var quest_guide_accepted := false
var pending_data := {}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	transition_layer = CanvasLayer.new()
	transition_layer.layer = 100 #Top most layer
	transition_rect = ColorRect.new()
	transition_rect.color = Color.BLACK
	#Make colorRect fill its parent (the CanvasLayer, which fills the viewport)
	transition_rect.anchor_right = 1.0 
	transition_rect.anchor_bottom = 1.0 
	#Hide it for now, and add it in the scene later on 
	transition_rect.visible = false
	transition_layer.add_child(transition_rect)
	#since scene manager is an autoload -> doesnt have a parent 
	#parent becomes root node 
	get_tree().root.add_child.call_deferred(transition_layer)
	

func request_world(level_name):
	change_scene("res://scenes/levels/%s.tscn" % level_name)
	print(level_name)

func request_battle(opponent_name, background, transition):
	pending_data = {
		"opponent": opponent_name,
		"background": background
	}
	SaveManager.save_game()  # Saves current position in overworld 
	change_scene("res://scenes/Battle/battle.tscn")
	print("battle")

func request_dialog(file_path: String):
	pending_data = {
		"dialog_file": file_path
	}
	add_scene("res://scenes/Story/story_scene.tscn")
	print("request_dialog")

func request_start(file_path: String): 
	pending_data = {
		"dialog_file": file_path
	}
	change_scene("res://scenes/Story/story_scene.tscn")
	print("request_start")

func register_story_scene(story_scene):
	# Important: disconnect old if needed
	if story_scene.quest_accepted.is_connected(_on_story_quest_accepted):
		story_scene.quest_accepted.disconnect(_on_story_quest_accepted)

	story_scene.quest_accepted.connect(_on_story_quest_accepted)

func _on_story_quest_accepted(title, message):
	print("SceneManager: relaying quest_requested")
	quest_guide_accepted = true
	quest_requested.emit()
	QuestNotification.add_notification_to_queue(title, message)
	

func transition_out(effect: String = "fade"): 
	match effect: 
		"fade": 
			_fade_out()
		"slide": 
			_slide_out()
		_: #everything else 
			_fade_out()
		

func transition_in(effect: String = "fade"): 
	match effect: 
		"fade": 
			_fade_in()
		"slide": 
			_slide_in()
		_: #everything else 
			_fade_in()
		
func _fade_in(): 
	transition_rect.position = Vector2.ZERO 
	transition_rect.modulate.a = 1 
	#make the layer really high 
	transition_rect.visible = true 
	transition_rect.z_index = 999
	
	#start animating 
	var tween = create_tween()
	tween.tween_property(transition_rect, "modulate:a", 0.0, transition_time)
	tween.tween_callback(func(): 
		transition_rect.visible = false 
		transition_in_completed.emit()
		print("function fade in was called")
	)
	
func _fade_out(): 
	#reset position of texture rect 
	transition_rect.position = Vector2.ZERO
	transition_rect.modulate.a = 0
	#make the layer really high 
	transition_rect.z_index = 999
	transition_rect.visible = true 
	
	#start animating 
	var tween = create_tween()
	tween.tween_property(transition_rect, "modulate:a", 1.0, transition_time)
	tween.tween_callback(func(): 
		transition_out_completed.emit()
		print("fuction fade out was called")
		) #callback is a function called when another process is done
	

func _slide_out(): 
	transition_rect.modulate.a =1 
	transition_rect.visible = true 
	transition_rect.z_index = 999
	
	#set initial position to the left of the screen 
	var viewport_size = get_viewport_rect().size
	transition_rect.position.x = viewport_size.x 
	transition_rect.position.y = 0
	var tween = create_tween()
	tween.tween_property(transition_rect, "position:x", 0, transition_time)
	tween.tween_callback(func():
		transition_out_completed.emit())
	

func _slide_in(): 
	transition_rect.modulate.a =1 
	transition_rect.visible = true 
	transition_rect.z_index = 999
	
	#set initial position to the right of the screen 
	var viewport_size = get_viewport_rect().size
	transition_rect.position.x = 0
	transition_rect.position.y = 0
	var tween = create_tween()
	tween.tween_property(transition_rect, "position:x", -viewport_size.x, transition_time)
	tween.tween_callback(func(): 
		transition_rect.visible = false 
		transition_out_completed.emit())

#change scene to other stuff eg main menu or world map 
func change_scene(path: String): 
	#print("change_scene called " + path)
	#print("Current scene: ", get_tree().current_scene.name if get_tree().current_scene else "None")
	#print("File exists: ", ResourceLoader.exists(path))
	
	await get_tree().process_frame
	#get_tree().change_scene_to_file(path)
	
	var error = get_tree().change_scene_to_file(path)
	print("Change scene result: ", error)
	
	if error != OK:
		printerr("Failed to change scene! Error code: ", error)
	print("change scene works")
	
func add_scene(path:String): 
	await get_tree().process_frame
	# Load the scene
	var scene = load(path)
	
	# Instance the scene
	var instance = scene.instantiate()
	
	# Add it as a child to the current node
	add_child(instance)
	
