class_name QuestItem extends Button

var quest : Quest 

@onready var step_label: Label = $stepLabel
@onready var title_label: Label = $titleLabel

func initialize(quest_data : Quest, q_state) -> void: 
	quest = quest_data
	title_label.text = quest_data.title
	
	if q_state.is_complete: 
		step_label.text = "Complete"
		step_label.modulate = Color.AQUAMARINE
	else: 
		var step_count : int = quest_data.steps.size()
		var completed_count : int = q_state.completed_steps.size()
		step_label.text = "quest step: " + str(completed_count) + "/" + str(step_count)
		
	
