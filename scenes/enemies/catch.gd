extends NodeState


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_enter(): 
	print("Catch!")

#extends Node2D
#
#@onready var interactable_component: InteractableComponent = $InteractableComponent
#@onready var interactable_label_component: Control = $InteractableLabelComponent
#@onready var story_path = "res://resources/story/Test2.json"
#
#var is_interactable = false 
#
## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#interactable_component.interactable_activated.connect(on_interactable_activated) # Replace with function body.
	#interactable_component.interactable_deactivated.connect(on_interactable_deactivated)
	#interactable_label_component.hide() #hide the component by default
#
#func on_interactable_activated() -> void: 
	#is_interactable = true
	#interactable_label_component.show()
#
#func on_interactable_deactivated() -> void: 
	#is_interactable = false 
	#interactable_label_component.hide()
	#
##upon pressing "F"
#func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action_pressed("show_dialog") and is_interactable:
		#SceneManager.request_dialog(story_path)
		##pauses the game world while dialog plays 
		#get_tree().current_scene.process_mode = Node.PROCESS_MODE_DISABLED
		##SceneManager.change_scene()
		##handle the transition screen l8r
