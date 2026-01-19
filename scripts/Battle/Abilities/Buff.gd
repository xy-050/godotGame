extends Node

const ABILITY_TRIGGER_EVENT = "card_played" 

@export var damage_buff_percent: float = 30.0

func trigger_ability(battle_manager_reference, card_with_ability, input_manager_reference, trigger_event): 
	if ABILITY_TRIGGER_EVENT != trigger_event: 
		return 
	#hide button n enable inputs 
	battle_manager_reference.enable_end_turn_button(false)
	input_manager_reference.inputs_disabled = true
	
	await battle_manager_reference.wait(1.0)
	
	# APPLY THE BUFF to all player cards on battlefield
	for card in battle_manager_reference.player_cards_on_battlefield:
		if card.has("damage_multiplier"):
			card.damage_multiplier += damage_buff_percent / 100.0
		else:
			card.damage_multiplier = 1.0 + (damage_buff_percent / 100.0)
	
	battle_manager_reference.destroy_card(card_with_ability, "Player")
	
	await battle_manager_reference.wait(1.0)
	
	#show button n enable inputs 
	battle_manager_reference.enable_end_turn_button(true)
	input_manager_reference.inputs_disabled = false
	print("ability triggered!")
