extends CanvasLayer

@onready var bg_music = %MenuMusic
@onready var new_game_button: Button = %StartGameButton
@onready var save_button: Button = %SaveGameButton
@onready var quit_button: Button = %ExitGameButton
@onready var main_story = "res://resources/story/main_story/mainStory.json"

func _ready() -> void:
	#play music 
	bg_music.play()
	new_game_button.pressed.connect(_on_new_game_button_pressed)
	save_button.pressed.connect(_on_save_game_button_pressed)
	quit_button.pressed.connect(_on_exit_game_button_pressed)
	#callback only once 
	SceneManager.transition_out_completed.connect(on_transition_out_completed, CONNECT_ONE_SHOT)

func _on_new_game_button_pressed() -> void:
	#change scene first 
	SceneManager.transition_out()
	

func on_transition_out_completed(): 
	#specify which scene you want to go to: 
	#SceneManager.change_scene("res://scenes/Story/story_scene.tscn")
	#load the story file 
	SceneManager.request_start(main_story)


func _on_save_game_button_pressed() -> void:
	pass # Replace with function body.


func _on_exit_game_button_pressed() -> void:
	get_tree().quit()
