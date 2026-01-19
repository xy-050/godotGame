extends Node

const BOMB_DAMAGE = 50 

const ABILITY_TRIGGER_EVENT = "card_placed" 

func trigger_ability(battle_manager_reference, card_with_ability, input_manager_reference, trigger_event): 
	if ABILITY_TRIGGER_EVENT != trigger_event: 
		return 
	#hide button n enable inputs 
	battle_manager_reference.enable_end_turn_button(false)
	input_manager_reference.inputs_disabled = true
	
	await battle_manager_reference.wait(1.0)
	
	var cards_to_destroy = []
	
	#check if there are minions in battlefield. if there are, deal damage to all of them. 
	
	#for opponent in battle_manager_reference.opponents_on_battlefield:
	##Card deal damage to each other  
		#opponent.hp = max(0, opponent.hp - BOMB_DAMAGE)
		#opoonent.get_node("HP").text = str(opponent.hp)
		#
		#if opponent.hp <= 0:
			#cards_to_destroy.append(opponent)
	
	#if there aren't any, just deal damage to the boss directly 
	battle_manager_reference.current_opponent.hp = max(0, battle_manager_reference.current_opponent.hp - BOMB_DAMAGE)
	battle_manager_reference.current_opponent.get_node("HP").text = str(battle_manager_reference.current_opponent.hp)
	if battle_manager_reference.current_opponent.hp <= 0:
			cards_to_destroy.append(battle_manager_reference.current_opponent)
	
	await battle_manager_reference.wait(1.0)
	
	if cards_to_destroy.size() > 0: 
		for card in cards_to_destroy: 
			battle_manager_reference.destroy_card(card, "Opponent")
	
	battle_manager_reference.destroy_card(card_with_ability, "Player")
	
	await battle_manager_reference.wait(1.0)
	
	#show button n enable inputs 
	battle_manager_reference.enable_end_turn_button(true)
	input_manager_reference.inputs_disabled = false
	print("ability triggered!")

func get_direct_damage(): 
	return BOMB_DAMAGE
