#QuestManager 
extends Node2D 

signal quest_updated(quest)


const QUEST_DATA_LOCATION: String = "res://scripts/Quest/quests/"

#list of all quests in the game 
var quests: Array[Quest]

#list of current quests player has taken 
var current_quests: Array  = [] 
 


func _ready() -> void:
	#gather all quests 
	gather_quest_data()
	pass


func gather_quest_data() -> void: 
	#gather all quests resources and add to quests array 
	var quest_files : PackedStringArray = DirAccess.get_files_at(QUEST_DATA_LOCATION)
	quests.clear()
	for quest in quest_files: 
		quests.append(load(QUEST_DATA_LOCATION + "/" + quest) as Quest)
		pass 
	pass 


#update the status of a quest 
#completed step argument is optional, and so is _is_complete. 
#Any subsequent arguments passed in must be optional too 
#example arguments: update_quest("xx", "xx") OR update_quest("xx") OR update_quest("xx", "xx", "xx") 
func update_quest(_title: String, _completed_step: String = "", _is_complete: bool = false) -> void: 
	var quest_idx : int = get_quest_index_by_title(_title)
	if quest_idx == -1: 
		#Quest was not found: if player does not have quest in current_quests, add it in 
		var new_quest : Dictionary = {title = _title, is_complete = _is_complete, completed_steps = []}
		if _completed_step != "": 
			new_quest.completed_steps.append(_completed_step.to_lower())
		
		current_quests.append(new_quest)
		quest_updated.emit(new_quest)
		#Display a notification that quest was added 
		PlayerManager.queue_notification("Quest Started", _title)
		
		pass 
	else: 
		#quest was found, update it 
		var quest = current_quests[quest_idx]
		#if player somehow already completed some steps of the quest without actlly starting the quest 
		if _completed_step != "" and quest.completed_steps.has(_completed_step) == false: 
			quest.completed_steps.append(_completed_step.to_lower())
		quest.is_complete = _is_complete
		
		quest_updated.emit(quest)
		#display a notification that quest was completed or updated 
		if quest.is_completed: 
			PlayerManager.queue_notification("Quest Completed!", _title)
			disperse_quest_rewards(find_quest_by_title(_title))
		else: 
			PlayerManager.queue_notification("Quest Updated", _title + ": " + _completed_step)
		
		
			#if quest is completed, mark it as complete 
	pass 

#Update TrustManager and Inventory: give the rewards to player 
func disperse_quest_rewards(quest: Quest) -> void: 
	var _message : String = str (quest.trust ) + "trust"
	
	TrustManager.gain_trust(quest.trust)
	for i in quest.reward_items: 
		PlayerManager.INVENTORY_DATA.add_item(i.item, i.quantity)
		_message += ", " + i.item.name + " x" + str(i.quantity)
	PlayerManager.queue_notification("Quest Rewards Received!", _message)
	pass 

#provide a quest and return the current quest associated with it. 
func find_current_quest(_quest : Quest) -> Dictionary: 
	for q in current_quests:
		if q.title == _quest.title: 
			return q 
		
	return {title = "not found", is_complete = false, completed_steps = ['']}

#find the title 
func find_quest_by_title(_title: String) -> Quest: 
	for quest in quests: 
		if quest.title.to_lower() == _title.to_lower(): 
			return quest
	return null 

#find quest by title name and return index in current quest array 
func get_quest_index_by_title (_title: String) -> int: 
	for i in current_quests.size(): 
		if current_quests[i].title.to_lower() == _title.to_lower(): 
			return i
	#failed to find quest 
	return -1 

#sort quests: first active (asc) then completed (asc)
func sort_quests() -> void: 
	var active_quests : Array = []
	var completed_quests: Array = []
	for q in current_quests: 
		if q.is_complete: 
			completed_quests.append(q)
		else: 
			active_quests.append(q)
	active_quests.sort_custom(sort_quests_ascending)
	completed_quests.sort_custom(sort_quests_ascending)
	
	current_quests = active_quests
	current_quests.append_array(completed_quests)
	
	

#sort quests alphabetically, ascending  
func sort_quests_ascending(quest1, quest2): 
	if quest1.title < quest2.title: 
		return true 
	return false
