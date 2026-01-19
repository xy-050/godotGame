#TODO: Do i want to destroy card when hp is 0 or pass it to opponent. 
#Issue where player card attacks after opponent card? 
#implement the feature using: card_slot_found.get_node("Area2D/CollisionShape2D").disabled = true that allows player to replace their cards on field
#refactor end turn button visiibility n disable it  
#Issue: the collision for attacking again during player's turn has been disabled? 
#Issue: Player cards will attack after opponent cards attack. is this desired logic? refer to HSR 
#?? why does event card return to hand after drawing a card n being discarded? 
## Issue: ?? why can we play an event card while opponent is attacking? 
## abilities to be played -> a stack that stores all the abilities' effects. should be in order 
#Implement steal mechanic - default 30s 
#ohhh the event card counts as being played because it's drag n release......ohhhhh.... 
#DO i want enemy cards to do combos? cuz rn they dont.... but if i do, hmmm.....i'll need to change direct attack n attack. 
# if we go with the combo plan, we can just have a variable that calculates the amount of damage a series of cards do. 
#code for queue: var notification =  notification_queue.pop_front()

#Attempt 2: 
#card 2 cannot be inserted into the arena
# 
extends Node

@onready var bg_music = $"../battle_music"
@onready var animation_effect = %AnimationEffect
@onready var ultimate_effect: AnimatedSprite2D = $"../UltimateEffect"
@onready var background = $"../Backgrounds/Center"
@onready var opponent_sprite = $"../Opponent"

const SMALL_CARD_SCALE = 0.7 
const CARD_MOVE_SPEED = 0.2 
const TIMER = 1.0 
const STARTING_PLAYER_HEALTH = 100 
const STARTING_OPPONENT_HEALTH = 1000
const BATTLE_POS_OFFSET = 25
const DEFAULT_MUSIC = "Bonds"
const DEFAULT_ENEMY = "BeyondX"

var battle_timer
var patience_timer #patience timer is the number of seconds before the entities get pissed and try to steal your cards 
var empty_memory_card_slots = [] 
var opponent_skills_to_attack = []
var player_cards_on_battlefield = []
var player_cards_that_attacked_this_turn = []
var abilities_to_be_played = []
var after_played = []
var card_placed = []


var player_health 
var opponent_health
var opponent_name
var music 
var is_opponents_turn = false  
var player_is_attacking = false 
var current_turn: int = 0 
var opponent_ai: OpponentAI
var current_opponent_data: OpponentData


var current_opponent: OpponentBase  # Store the opponent instance
var opponent_skill_cooldowns: Dictionary = {}  # Track cooldowns

#Signals for expression change 
signal player_damaged(damage_amount)
signal opponent_damaged(damage_amount)
signal opponent_skill_used(skill_name)
signal battle_ended(winner)

func _ready() -> void:
	#hide notifications: temporaray band-aid 
	QuestNotification.visible = false 
	
	
	battle_timer = $"../BattleTimer"
	#battle timer only goes once 
	battle_timer.one_shot = true
	#wait time  
	battle_timer.wait_time = TIMER
	#set strategy:
	opponent_ai = OpponentAI.new(self)
	
	
	player_health = STARTING_PLAYER_HEALTH
	$"../PlayerHealth".text = str(player_health)
	opponent_health = STARTING_OPPONENT_HEALTH
	$"../OpponentHealth".text = str(opponent_health)
	
		# Get battle data from SceneManager
	if SceneManager.pending_data.has("opponent"):
		opponent_name = SceneManager.pending_data["opponent"]
		var bg_name = SceneManager.pending_data["background"]
		print(bg_name)
		var bg_path = "res://assets/Battle/Backgrounds/" + bg_name + ".png"
		print(bg_path)
		
		background.texture = load(bg_path)
		print("success")
		
		# Clear the pending data after using it
		SceneManager.pending_data.clear()
		
		# Use the data to setup the battle
		setup_battle(opponent_name)
	else:
		# Default battle setup if no data provided
		setup_battle(DEFAULT_ENEMY)
	
	#set the turn counter to 1:  
	current_turn = 1 
	update_turn_display()
	# Fade in from black
	SceneManager.transition_in("fade")
	
	#hide the ultimate effect 
	ultimate_effect.hide()

func setup_battle(opponent_name: String):
	print("Setting up battle against: ", opponent_name)
	
	var opponent_data_path = "res://scripts/Battle/opponents/" + opponent_name.to_lower() + ".tres"
	
	if ResourceLoader.exists(opponent_data_path):
		current_opponent_data = load(opponent_data_path)
	else:
		printerr("Opponent data not found: ", opponent_data_path)
	
	
	
	# Load the opponent 
	current_opponent = current_opponent_data.get_opponent_instance()
	#parse and clean, make sure opponent name has no "_" anywhere
	
	if current_opponent:
		print("Loaded opponent: ", current_opponent.opponent_name)
		print("Available skills: ", current_opponent.get_all_skills())
		
		# Initialize cooldowns
		for skill_name in current_opponent.get_all_skills():
			opponent_skill_cooldowns[skill_name] = 0
	else:
		printerr("Failed to load opponent instance!")
		return
	
	
	if current_opponent:
		print("Loaded opponent: ", current_opponent.opponent_name)
		print("Available skills: ", current_opponent.get_all_skills())
	
	# Initialize cooldowns
	for skill_name in current_opponent.get_all_skills():
		opponent_skill_cooldowns[skill_name] = 0
	
	
	# Set opponent health from data
	opponent_health = current_opponent_data.hp
	$"../OpponentHealth".text = str(opponent_health)
	
	# Configure AI with opponent data
	opponent_ai.set_opponent_data(current_opponent_data)
	
	
	if current_opponent_data.has_minions: 
		var number_of_minions = current_opponent_data.get_minion_number()
		#maximum of 3 minions on the field at any time
		for minion in number_of_minions: 
			#empty_memory_card_slots.append($"../CardSlots/EnemyCardSlot") 
			#include the offset value between each append 
			pass 
		pass 
	
	
	# Set opponent sprite/portrait 
	if current_opponent_data.sprite_path != "":
		if ResourceLoader.exists(current_opponent_data.sprite_path):
			opponent_sprite.sprite_frames = load(current_opponent_data.sprite_path + "default/")
			opponent_sprite.play("default")
		
	
	# 2. Get music from opponent data
	var music_name = current_opponent_data.music_name
	if music_name == "":
		music_name = DEFAULT_MUSIC 
	
	# Build the full path
	var music_path = "res://assets/Music/" + music_name + ".mp3"
	
	# Load and play the music
	if ResourceLoader.exists(music_path):
		bg_music.stream = load(music_path)
		bg_music.play()
	else:
		printerr("Music file not found: ", music_path)
		
	
func direct_damage(damage): 
	#deal dmg to opponent 
	opponent_health = max(0, opponent_health - damage)
	$"../OpponentHealth".text = str(opponent_health)

func _on_end_turn_button_pressed() -> void:
	is_opponents_turn = true 
	$"../CardManager".unselect_selected_memories()
	for card in player_cards_that_attacked_this_turn: 
		if card.ability_script: 
			card.ability_script.end_turn_reset()
	player_cards_that_attacked_this_turn = []
	opponent_turn()

func opponent_turn():
	$"../EndTurnButton".disabled = true 
	$"../EndTurnButton".visible = false 
	
	await wait(TIMER)
	
	# Select a skill to use
	var skill_to_use = opponent_ai.select_skill_to_use(
		current_opponent,
		opponent_skill_cooldowns,
		opponent_health,
		current_opponent_data.hp
	)
	
	if skill_to_use:
		await execute_opponent_skill(skill_to_use)
	else:
		# Normal attack
		await execute_normal_attack()
	
	# Decrement cooldowns
	for skill_name in opponent_skill_cooldowns:
		if opponent_skill_cooldowns[skill_name] > 0:
			opponent_skill_cooldowns[skill_name] -= 1

	
	#Reset player deck draw 
	end_opponent_turn()

func execute_opponent_skill(skill_name: String):
	var skill_data = current_opponent.get_skill(skill_name)
	
	# Play animations
	await play_skill_animations(skill_name, skill_data)
	
	# Load and execute skill script
	if skill_data.has("script_path"):
		var skill_script = load(skill_data["script_path"]).new()
		await skill_script.execute(self, skill_data)
	
	# Set cooldown
	if skill_data.has("cooldown"):
		opponent_skill_cooldowns[skill_name] = skill_data["cooldown"]
	
	emit_signal("opponent_skill_used", skill_name)


func execute_normal_attack():
	attack_player(current_opponent.normal_attack_damage)
	await play_normal_attack_opponent(current_opponent.opponent_name)

func play_skill_animations(skill_name: String, skill_data: Dictionary):
	# Play ultimate effect if exists
	if skill_data.has("ultimate_animation"):
		if ultimate_effect.sprite_frames.has_animation(skill_data["ultimate_animation"]):
			ultimate_effect.show()
			ultimate_effect.play(skill_data["ultimate_animation"])
			await ultimate_effect.animation_finished
			ultimate_effect.hide()
	
	# Play main animation
	if skill_data.has("animation_name"):
		if animation_effect.has_animation(skill_data["animation_name"]):
			animation_effect.play(skill_data["animation_name"])
			await animation_effect.animation_finished
	

#attack boss 
func direct_attack(attacking_card, attacker): 
	var new_pos_y = 0
	#if attacker == "Opponent": 
		#new_pos_y = 1080
	#else: 
	$"../InputManager".inputs_disabled = true 
	enable_end_turn_button(false)
	player_is_attacking = true 
	player_cards_that_attacked_this_turn.append(attacking_card)
		
	var new_pos = Vector2(attacking_card.global_position.x, new_pos_y)
	
	attacking_card.z_index = 5 
	
	var tween = get_tree().create_tween()
	tween.tween_property(attacking_card, "global_position", new_pos, CARD_MOVE_SPEED)
	await wait(0.15)
	
	opponent_health = max(0, opponent_health - attacking_card.attack)
	$"../OpponentHealth".text = str(opponent_health)
		 
	
	#var tween2 = get_tree().create_tween()
	#tween2.tween_property(attacking_card, "global_position", attacking_card.card_slot_card_is_in.global_position, CARD_MOVE_SPEED)
	
	#card attack animation 
	
	
	attacking_card.z_index = 0
	await wait(1.0)
	
	if attacker == "Player": 
		if attacking_card.ability_script: 
			await attacking_card.ability_script.trigger_ability(self, attacking_card, $"../InputManager", "after_attack")
		
		player_is_attacking = false
		$"../InputManager".inputs_disabled = false 
		enable_end_turn_button(true)
	print("Direct attack")

#attack minion 
func attack(attacking_card, defending_card, attacker): 
	if attacker == "Player": 
		$"../InputManager".inputs_disabled = true 
		enable_end_turn_button(false)
		$"../CardManager".selected_memory = null 
		player_cards_that_attacked_this_turn.append(attacking_card)
	
	
	attacking_card.z_index = 5
	var new_pos = Vector2(defending_card.global_position.x, defending_card.global_position.y + BATTLE_POS_OFFSET)
	
	##Attacking animation:
	#var tween = get_tree().create_tween()
	#tween.tween_property(attacking_card, "global_position", new_pos, CARD_MOVE_SPEED)
	#await wait (0.15)
	#var tween2 = get_tree().create_tween()
	#tween2.tween_property(attacking_card, "global_position", attacking_card.card_slot_card_is_in.global_position, CARD_MOVE_SPEED)
	
	#card attack animation 
	
	
	#Card deal damage to each other  
	defending_card.hp = max(0, defending_card.hp - attacking_card.attack)
	defending_card.get_node("HP").text = str(defending_card.hp)
	
	#attacking_card.hp =  max(0, attacking_card.hp - defending_card.attack)
	#attacking_card.get_node("HP").text = str(attacking_card.hp)
	
	#await 1s 
	await wait(1.0)
	attacking_card.z_index = 0
	
	var card_was_destroyed = false 
	
	#Destroy cards once hp reach 0 
	if attacking_card.hp == 0: 
		destroy_card(attacking_card, attacker)
		card_was_destroyed = true 
	if defending_card.hp == 0: 
		if attacker == "Player": 
			#destroy_card(defending_card, "Opponent")
			destroy_minion(defending_card, "Opponent")
		else: 
			destroy_card(defending_card, "Player")
		card_was_destroyed = true 
	
	#remove cards from arrays 
	if card_was_destroyed: 
		await wait(1.0)
	
	if attacker == "Player": 
		if attacking_card.ability_script: 
			await attacking_card.ability_script.trigger_ability(self, attacking_card, $"../InputManager", "after_attack")
		
		player_is_attacking = false
		$"../InputManager".inputs_disabled = false 
		enable_end_turn_button(true)
	
	print("Attack")

func attack_player(damage: int): 
	print("attempt to damage player")
	#deal dmg to player 
	player_health = max(0, player_health - damage)
	$"../PlayerHealth".text = str(player_health)
	#expression change: 
	#emit_signal("player_damaged", opponent_name.attack)

func destroy_card(card, card_owner): 
	print("attempt to destroy card")
	#Return trust to player based on the amount of trust discarded 
	
	var new_pos 
	if card_owner == "Player": 
		card.defeated = true 
		card.get_node("Area2D/CollisionShape2D").disabled = true
		new_pos = $"../PlayerDiscard".global_position 
		#Move card to discard pile 
		if card in player_cards_on_battlefield: 
			player_cards_on_battlefield.erase(card)
			
		
		#if the card was inside the card slot, enable the collision of the card slot 
		#if card.card_slot_card_is_in: 
			#card.card_slot_card_is_in.get_node("Area2D/CollisionShape2D").disabled = false 
	#else: 
		#new_pos = $"../OpponentDiscard".global_position
		##if card destroyed belongs to opponent, check if it is on battlefield 
		#if card in opponent_cards_on_battlefield: 
			##Move card to discard pile 
			#opponent_cards_on_battlefield.erase(card)
		
	if card.card_slot_card_is_in: 
		card.card_slot_card_is_in.card_in_slot = false ## 
	
	card.card_slot_card_is_in = null  ##
	
	#animation 
	var tween = get_tree().create_tween()
	tween.tween_property(card, "global_position", new_pos, CARD_MOVE_SPEED)
	await wait (0.15)

func destroy_minion(card, minion): 
	print("minion is going to be destroyed")
	#play death animation for minion 
	#remove minion from opponent_minions_on_battlefield
	
	

func enemy_card_selected(opponent): 
	var attacking_card = $"../CardManager".selected_memory
	if attacking_card:
		#if opponent is still in battlefield (like if there is even a targettable opponent)
		if opponent in opponent_skills_to_attack: 
		#if defending_card in opponent_cards_on_battlefield: 
			if player_is_attacking == false and attacking_card not in player_cards_that_attacked_this_turn:  
				$"../CardManager".selected_memory = null 
				attack(attacking_card, opponent, "Player")

func update_turn_display(): 
	$"../TurnDisplay".text = "Turn:" + str(current_turn)

##Opponent playing code 
#func try_play_card(): 
	##Play card
	##get random empty slot to play the card in 
	##var opponent_hand = $"../OpponentHand".opponent_hand
	###if no cards in opp hand, end turn 
	##if opponent_hand.size() == 0: 
		##end_opponent_turn()
		##return 
	##var random_empty_memories_card_slot = empty_memory_card_slots.pick_random()
	##empty_memory_card_slots.erase(random_empty_memories_card_slot)
	###Play card with highest atk 
	###Start by assuming the first card in hand has highest atk
	###var current_card = get_card_with_highest_atk(opponent_hand)
	##var current_card = opponent_ai.select_card_to_play(opponent_hand)
	##
	###Animate card to position 
	###if more than 1 minion is missing from field and opponent still has minions, then deploy the new minion and 
	##var tween = get_tree().create_tween()
	##tween.tween_property(current_card, "global_position", random_empty_memories_card_slot.global_position, CARD_MOVE_SPEED)
	##var tween2 = get_tree().create_tween()
	##tween2.tween_property(current_card, "scale", Vector2(SMALL_CARD_SCALE, SMALL_CARD_SCALE), CARD_MOVE_SPEED)
	##current_card.get_node("AnimationPlayer").play("card_flip")
	##
	###Remove card from opponent's hand
	##$"../OpponentHand".remove_card_from_hand(current_card)
	##current_card.card_slot_card_is_in = random_empty_memories_card_slot
	##opponent_cards_on_battlefield.append(current_card)
	##
	###Wait a bit 
	##await wait(TIMER)
	#
	##play opponent skill:
	#play_skill_effect_opponent(opponent_name, opponent_skill)
	#
	#
	##attack the player 
	#attack_player(opponent_name)
	#play_normal_attack_opponent(opponent_name)
	#
	#
	#
	#end_opponent_turn()
	
	
func end_opponent_turn(): 
	$"../Deck".reset_draw()
	$"../CardManager".reset_played_memories()
	is_opponents_turn = false 
	player_is_attacking = false ##
	$"../EndTurnButton".visible = true
	$"../EndTurnButton".disabled = false  
	current_turn += 1 
	update_turn_display()

func wait(wait_time): 
	battle_timer.wait_time = wait_time
	#Wait a bit 
	battle_timer.start()
	await battle_timer.timeout

func enable_end_turn_button(is_enabled): 
	if is_enabled: 
		$"../EndTurnButton".visible = true
		$"../EndTurnButton".disabled = false  
	else: 
		$"../EndTurnButton".visible = false
		$"../EndTurnButton".disabled = true  

func play_ability_animation(skill): 
	pass


func _on_battle_music_finished() -> void:
	bg_music.play() # Replace with function body.

#discard the card and place it back into the deck 
func discard_card(card):
	#print("=== DISCARD CALLED ===")
	#print("Card object: ", card)
	#print("Card name: ", card.name if card else "NULL")
	#print("Card is valid: ", is_instance_valid(card))
	
	#discard card only works for memories 
	if card.card_type != "memory": 
		return
	
	 #Flip over animation
	var anim_player = find_animation_player(card)
	if anim_player:
		anim_player.play("reverse_card_flip")
		await wait(0.15)
		print("animation completed")
	else:
		print("No AnimationPlayer!")
	
	
	
	#Animation for discard 
	var new_pos = $"../Deck".global_position 
	var tween = get_tree().create_tween()
	tween.tween_property(card, "global_position", new_pos, CARD_MOVE_SPEED)
	await wait (0.15)
	print("Join discard pile")

	
	#Remove from playerhand if it's there 
	var player_hand_reference = $"../PlayerHand"
	if card in player_hand_reference.player_hand:
		player_hand_reference.player_hand.erase(card)
		print("removed from hand")
	
	# Remove from battlefield if it's there
	if card in player_cards_on_battlefield:
		player_cards_on_battlefield.erase(card)
		#get back the trust value 
		TrustManager.current_trust += card.trust_cost
		$"../TrustDisplay".update_display()
		
		print("removed from battlefield")
	
	## Free up the card slot if it's in one
		if card.card_slot_card_is_in:
			card.card_slot_card_is_in.card_in_slot = false
			card.card_slot_card_is_in = null
			print("freed from card slot")
		

		#add back to deck 
		$"../Deck".player_deck.append(card.card_name)
		$"../Deck".player_deck.shuffle()
		
		#remove from the whole scene all together 
		card.queue_free()

func find_animation_player(node):
	if node is AnimationPlayer:
		return node
	for child in node.get_children():
		if child is AnimationPlayer:
			return child
		var result = find_animation_player(child)
		if result:
			return result
	return null

func battle_end(winner: String):
	print("Battle ended! Winner: ", winner)
	emit_signal("battle_ended", winner)
	
	# Disable input
	$"../InputManager".inputs_disabled = true
	$"../EndTurnButton".disabled = true
	
	SaveManager.restore_player_position()


func play_normal_attack(card):
	if !card.card_type == "event":
		return
	# Event cards: play only AnimationPlayer
	if animation_effect.has_animation(card.card_name):
		animation_effect.play(card.card_name)
		await animation_effect.animation_finished

func play_skill_effect_opponent(opponent_name, skill_name): 
	if ultimate_effect.sprite_frames.has_animation(skill_name):
		ultimate_effect.show()
		ultimate_effect.play(opponent_name)
		await ultimate_effect.animation_finished
		ultimate_effect.hide()

	if animation_effect.has_animation(skill_name): 
		animation_effect.play(opponent_name + skill_name)
		await animation_effect.animation_finished

func play_normal_attack_opponent(opponent_name):
	if animation_effect.has_animation(opponent_name):
		animation_effect.play(opponent_name)
		await animation_effect.animation_finished


func play_ultimate_effect(card): 
	if ultimate_effect.sprite_frames.has_animation(card.card_name):
		ultimate_effect.show()
		ultimate_effect.play(card.card_name)
		await ultimate_effect.animation_finished
