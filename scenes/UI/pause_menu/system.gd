class_name SystemUI extends Control

@onready var save_button: Button = $saveButton
@onready var load_button: Button = $loadButton
@onready var quit_button: Button = $quitButton
@onready var return_button: Button = $returnButton
var is_paused = true

func _ready() -> void:
	
	save_button.pressed.connect(_on_save_pressed)
	load_button.pressed.connect(_on_load_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	return_button.pressed.connect(_on_return_pressed)


func _on_save_pressed() -> void: 
	print("Try to save game")
	if is_paused == false: 
		print("unable to save game")
		return
	SaveManager.save_game()
	print("Save Manager should have saved the game")
	PauseMenu.hide_pause_menu()
	pass 



func _on_load_pressed() -> void: 
	print("try to load game")
	if is_paused == false: 
		print("unable to load game")
		return
	SaveManager.load_game()
	print("Load game successful")
	PauseMenu.hide_pause_menu()
	pass 

func _on_quit_pressed() -> void: 
	get_tree().quit()

func _on_return_pressed() -> void:
	PauseMenu.close_system()
