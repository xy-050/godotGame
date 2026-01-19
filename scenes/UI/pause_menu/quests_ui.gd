class_name QuestUI extends Control

const QUEST_ITEM_REFERENCE : PackedScene = preload("res://scenes/UI/unique_buttons/quest_item.tscn")
const QUEST_STEP_ITEM: PackedScene = preload("res://scenes/Quest/quest_step_item.tscn")

@onready var quest_item_container: VBoxContainer = $ScrollContainer/MarginContainer/VBoxContainer
@onready var details_container: VBoxContainer = $VBoxContainer
@onready var description_label: Label = $VBoxContainer/DescriptionLabel
@onready var title_label: Label = $VBoxContainer/titleLabel
@onready var close_button: Button = $ClosePage

func _ready() -> void:
	if close_button:
		close_button.pressed.connect(_on_close_pressed)
		
	clear_quest_details()
	#whenever this 
	visibility_changed.connect(_on_visible_changed)
	pass 
	

#when quest is opened up, refresh every time 
func _on_visible_changed() -> void: 
	for i in quest_item_container.get_children(): 
		i.queue_free()
		
	clear_quest_details()
	
	if visible: 
		#update the list then sort them 
		QuestManager.sort_quests()
		for q in QuestManager.current_quests: 
			var quest_data: Quest = QuestManager.find_quest_by_title(q.title)
			if quest_data == null: 
				continue 
			var new_q_item : QuestItem = QUEST_ITEM_REFERENCE.instantiate()
			quest_item_container.add_child(new_q_item)
			new_q_item.initialize(quest_data, q)
			new_q_item.focus_entered.connect(update_quest_details.bind(new_q_item.quest))
			
			#connect to focus entered 
	
	
func update_quest_details(q: Quest) -> void: 
	#clear quest details 
	clear_quest_details()
	
	title_label.text = q.title
	description_label.text = q.description
	
	var quest_save = QuestManager.find_current_quest(q)
	for step in q.steps: 
		var new_step : QuestStepItem = QUEST_STEP_ITEM.instantiate()
		var step_is_complete : bool = false
		if quest_save.title != "not found": 
			step_is_complete = quest_save.completed_steps.has(step.to_lower())
		details_container.add_child(new_step)
		new_step.initialize(step, step_is_complete)
		
	 

#find quest and close it 
func _on_close_pressed() -> void:
	PauseMenu.close_quest()

func clear_quest_details() -> void:
	title_label.text = ""
	description_label.text = ""
	for c in details_container.get_children(): 
		if c is QuestStepItem: 
			c.queue_free()
			
