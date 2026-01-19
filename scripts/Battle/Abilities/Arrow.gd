extends Node

const ARROW_DAMAGE = 50 

const ABILITY_TRIGGER_EVENT = "card_placed"

#ability effect path
#const ABILITY_EFFECT_PATH = 

func trigger_ability(battle_manager_reference, card_with_ability, input_manager_reference, trigger_event): 
	
	if ABILITY_TRIGGER_EVENT != trigger_event: 
		return 
	
	
	#hide button n enable inputs 
	battle_manager_reference.enable_end_turn_button(false)
	input_manager_reference.inputs_disabled = true
	
	await battle_manager_reference.wait(1.0)
	
	battle_manager_reference.direct_damage(ARROW_DAMAGE)
	
	await battle_manager_reference.wait(1.0)
	
	#show button n enable inputs 
	battle_manager_reference.enable_end_turn_button(true)
	input_manager_reference.inputs_disabled = false
	print("ability triggered!")

func end_turn_reset(): 
	pass 
