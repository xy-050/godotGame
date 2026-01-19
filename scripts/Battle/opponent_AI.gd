class_name OpponentAI extends Node 

# Reference to battle manager for context
var battle_manager: Node
var opponent_data: OpponentData

@onready var accumulated_weight := 0.0



func _init(manager, data: OpponentData = null):
	battle_manager = manager
	if data:
		set_opponent_data(data)

func set_opponent_data(data: OpponentData):
	opponent_data = data

#return random skill to play 
func select_random_skill_to_play(opponent_skills: Array): 
	return opponent_skills.pick_random()


# Returns the best skill to play from opponent's hand
func select_skill_to_use(opponent: OpponentBase, cooldowns: Dictionary, current_hp: int, max_hp: int) -> String:
	var available_skills = []
	
	for skill_name in opponent.get_all_skills():
		var skill_data = opponent.get_skill(skill_name)
		
		# Check if on cooldown
		if cooldowns.get(skill_name, 0) > 0:
			continue
		
		# Check condition
		if not check_skill_condition(skill_data, current_hp, max_hp):
			continue
		
		available_skills.append(skill_name)
	
	# No skills available
	if available_skills.is_empty():
		return ""
	
	# AI decision based on opponent_data type
	if opponent_data.type == OpponentData.Type.CHANCE_BASED:
		return available_skills.pick_random()
	else:
		# Conditional - pick best skill based on situation
		return evaluate_best_skill(available_skills, opponent)

func check_skill_condition(skill_data: Dictionary, current_hp: int, max_hp: int) -> bool:
	if not skill_data.has("condition"):
		return true
	
	match skill_data["condition"]:
		"always":
			return true
		"hp_below_50":
			return current_hp < (max_hp * 0.5)
		"hp_below_30":
			return current_hp < (max_hp * 0.3)
		_:
			return true

func evaluate_best_skill(available_skills: Array, opponent: OpponentBase) -> String:
	var best_skill = available_skills[0]
	var best_score = 0.0
	
	for skill_name in available_skills:
		var skill_data = opponent.get_skill(skill_name)
		var score = 0.0
		
		# Score based on damage
		if skill_data.has("damage"):
			score += skill_data["damage"] * 0.5
		
		# Score based on healing
		if skill_data.has("healing"):
			score += skill_data["healing"] * 0.3
		
		# Prefer skills with lower cooldown
		if skill_data.has("cooldown"):
			score += (5 - skill_data["cooldown"]) * 2
		
		if score > best_score:
			best_score = score
			best_skill = skill_name
	
	return best_skill


func evaluate_max_combo_player_can_do(player_cards_on_battlefield: Array, player_hand: Array) -> float:
	var max_damage = 0.0
	
	# Simulate each possible play from hand
	for card in player_hand:
		var potential_damage = 0.0
		
		# Case 1: Card is a buff card
		if card.has("damage_buff_percent"):
			# Simulate buff being applied
			var buff_multiplier = 1.0 + (card.damage_buff_percent / 100.0)
			
			# Calculate buffed battlefield damage
			for battlefield_card in player_cards_on_battlefield:
				if battlefield_card.has("attack"):
					potential_damage += battlefield_card.attack * buff_multiplier
			
			# Check for combo with other cards in hand (buff + damage card)
			for other_card in player_hand:
				if other_card == card:
					continue
				
				# Bomb card after buff
				if other_card.has_method("get_direct_damage"):
					potential_damage += other_card.get_direct_damage() * buff_multiplier
				
				# Attack card after buff
				elif other_card.has("attack"):
					potential_damage += other_card.attack * buff_multiplier
		
		# Case 2: Card deals direct damage (like Bomb)
		elif card.has_method("get_direct_damage"):
			var base_damage = card.get_direct_damage()
			
			# Check if battlefield already has active buffs
			var active_multiplier = get_active_damage_multiplier(player_cards_on_battlefield)
			potential_damage = base_damage * active_multiplier
			
			# Add damage from existing battlefield cards
			potential_damage += calculate_buffed_battlefield_damage(player_cards_on_battlefield)
		
		# Case 3: Regular attack card
		elif card.has("attack"):
			var active_multiplier = get_active_damage_multiplier(player_cards_on_battlefield)
			potential_damage = card.attack * active_multiplier
			potential_damage += calculate_buffed_battlefield_damage(player_cards_on_battlefield)
		
		max_damage = max(max_damage, potential_damage)
	
	return max_damage


# Get current active buff multiplier from battlefield cards
func get_active_damage_multiplier(battlefield_cards: Array) -> float:
	var max_multiplier = 1.0
	
	for card in battlefield_cards:
		if card.has("damage_multiplier"):
			max_multiplier = max(max_multiplier, card.damage_multiplier)
	
	return max_multiplier


# Calculate total damage from buffed battlefield cards
func calculate_buffed_battlefield_damage(battlefield_cards: Array) -> float:
	var total_damage = 0.0
	
	for card in battlefield_cards:
		if card.has("attack"):
			var multiplier = card.damage_multiplier if card.has("damage_multiplier") else 1.0
			total_damage += card.attack * multiplier
	
	return total_damage


func evaluate_attack_consequence(attacker, target) -> float:  # Both Card nodes
	var consequence_score = 0.0
	
	# After this attack, will attacker be vulnerable to other player cards?
	var attacker_hp_after = max(0, attacker.hp - target.attack)
	
	if attacker_hp_after > 0:
		var player_cards = battle_manager.player_cards_on_battlefield
		for player_card in player_cards:
			if player_card == target:
				continue  # Skip the target we're attacking
			
			# Can another player card kill us after this?
			if player_card.attack >= attacker_hp_after:
				consequence_score -= 10  # Penalty for leaving attacker vulnerable
	
	return consequence_score



#attack the card that costs the most trust
func get_highest_cost_card(cards: Array):  # Returns a Card node
	var highest = cards[0]
	for card in cards:
		if card.trust_cost > highest.trust_cost:
			highest = card
	return highest


func get_card_with_highest_atk(opponent_hand): 
	var current_card_with_highest_atk = opponent_hand[0]
	for card in opponent_hand: 
		if card.attack > current_card_with_highest_atk.attack: 
			current_card_with_highest_atk = card
	return current_card_with_highest_atk
