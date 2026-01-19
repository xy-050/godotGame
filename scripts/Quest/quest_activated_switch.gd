@tool
class_name QuestActivatedSwitch extends QuestNode

enum CheckType {HAS_QUEST, QUEST_STEP_COMPLETE, ON_CURRENT_QUEST_STEP, QUEST_COMPLETED}

signal is_activated_changed(v: bool)

@export var check_type : CheckType = CheckType.HAS_QUEST : set = _set_check_type 
@export var remove_when_activated : bool = false 
@export var react_to_global_signal: bool = false 
@export var free_on_remove: bool = false

var is_activated : bool = false

func _ready() -> void:
	#connect to global signal 
	if react_to_global_signal: 
		QuestManager.quest_updated.connect(_on_quest_updated)
	check_is_activated()

func _on_quest_updated(_q : Dictionary) -> void: 
	check_is_activated()
	

func check_is_activated() -> void: 
	#get the saved quest 
	var quest: Dictionary = QuestManager.find_current_quest(linked_quest)
	if quest.title != "not found": 
		if check_type == CheckType.HAS_QUEST: 
			set_is_activated(true)
		elif check_type == CheckType.QUEST_COMPLETED: 
			var is_complete: bool = false
			if quest.is_complete is bool:  
				is_complete = quest.is_complete
			set_is_activated(is_complete)
		elif check_type == CheckType.QUEST_STEP_COMPLETE: 
			if quest_step > 0:
				if quest.completed_steps.has(get_step()): 
					set_is_activated(true)
				else: 
					set_is_activated(false)
					
			else: 
				set_is_activated(false)
		elif check_type == CheckType.ON_CURRENT_QUEST_STEP: 
			var step : String = get_step()
			#dont have step to check 
			if step == "N/A": 
				set_is_activated(false)
			else: 
				if quest.completed_steps.has(step): 
					set_is_activated(false)
				else: 
					var prev_step : String = get_previous_step()
					if prev_step == "N/A": 
						set_is_activated(true)
					elif quest.completed_steps.has(prev_step.to_lower()): 
						set_is_activated(true)
					else: 
						set_is_activated(false)
	else: 
		#deactivate it 
		set_is_activated (false)

func set_is_activated(_v: bool) -> void: 
	is_activated = _v
	is_activated_changed.emit(_v)
	if is_activated: 
		if remove_when_activated: 
			#hide children 
			hide_children()
		else: 
			#show the children 
			show_children()
	else: 
		if remove_when_activated: 
			#show children 
			show_children()
		else: 
			#hide children 
			hide_children()
			

func show_children(): 
	for c in get_children(): 
		c.visible = true 
		c.process_mode = Node.PROCESS_MODE_INHERIT

func hide_children(): 
	for c in get_children(): 
		c.set_deferred("visible", false) 
		c.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
		if free_on_remove: 
			c.queue_free()

func _set_check_type(v: CheckType) -> void:
	check_type = v
	
