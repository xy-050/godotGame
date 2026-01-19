#TODO: ## check for it to ensure no mistakes were made 
#Lag time from event card being played. Too long lag :( 
#ANIMATION FOR EVENT CARD PLAYED 
#fix the collision issue -> collision issue seems to appear to be the issue of playing too fast. introduce a await wait(0.5) for the thing to run  
extends Node2D
 
const COLLISION_MASK_CARD = 1 
const COLLISION_MASK_CARD_SLOT = 2 
const COLLISION_MASK_EVENT_PLAY_AREA = 32
const DEFAULT_CARD_MOVE_SPEED = 0.1 
const DEFAULT_CARD_SCALE = 0.7
const CARD_BIGGER_SCALE = 0.8
const CARD_SMALLER_SCALE = 0.6
const TRIGGER_EVENT_CARD_PLACED = "card_placed"
const TRIGGER_EVENT_AFT_ATK = "after_attack" 
#const TRIGGER_EVENT_C

var card_being_dragged 
var screen_size
var drag_offset = Vector2.ZERO 
var is_hovering_on_card 
var player_hand_reference
var played_memories_this_turn = false 
var selected_memory

#Ensure the screen size doesnt change 
func _ready() -> void:
	screen_size = get_viewport_rect().size
	player_hand_reference = $"../PlayerHand"
	$"../InputManager".connect("left_mouse_button_released", on_left_click_released)
	print(screen_size)
	

#Get the card to follow the mouse 
func _process(_delta: float) -> void:
	if card_being_dragged: 
		var target = get_global_mouse_position() + drag_offset
		target.x = clamp(target.x, 0, screen_size.x)
		target.y = clamp(target.y, 0, screen_size.y)
		#card_being_dragged.position = mouse_pos
		card_being_dragged.global_position = target
		#print("card shld be following mouse")
	

func card_clicked(card): 
	print("Card type: ", card)
	print("Card name: ", card.name if card else "NULL")
	print("Card script: ", card.get_script().resource_path if card and card.get_script() else "NO SCRIPT")
	#Card if card on battlefield or in hand 
	if card.card_slot_card_is_in: 
		#if it is opponents turn, do not allow player to attack 
		if $"../BattleManager".is_opponents_turn: 
			print("Blocked: opponent's turn")
			return 
			
		#if player's attacking, do not allow player to attack
		if $"../BattleManager".player_is_attacking:
			print("Blocked: player is attacking")
			return
		
		#Card cannot attack multiple times per turn 
		if card in $"../BattleManager".player_cards_that_attacked_this_turn: 
			print("Blocked: already attacked")
			return 
		
		#if $"../BattleManager".opponent_cards_on_battlefield.size() == 0:
		$"../BattleManager".direct_attack(card, "Player") 
		#else: 
			#select_card_for_battle(card)
	else: 
		#card in hand 
		start_drag(card)
		

func select_card_for_battle(card): 
	#Toggle selected card 
	if selected_memory: 
		#if card is already selected 
		if selected_memory == card: 
			card.global_position.y += 20 
			selected_memory = null 
		else: 
			selected_memory.global_position.y += 20 
			selected_memory = card 
			card.global_position.y -= 20
			
	else: 
		selected_memory = card 
		card.global_position.y -= 20 

func start_drag(card): 
	card_being_dragged = card
	drag_offset = card.global_position - get_global_mouse_position()
	card.scale = Vector2(DEFAULT_CARD_SCALE, DEFAULT_CARD_SCALE)
	#print("card being dragged") 

func finish_drag(): 
	card_being_dragged.scale = Vector2(CARD_BIGGER_SCALE, CARD_BIGGER_SCALE)
	
	#check for discard first 
	if is_card_over_deck():
		$"../BattleManager".discard_card(card_being_dragged)
		card_being_dragged = null
		return
	
	var card_slot_found = raycast_check_for_card_slot()
	if card_slot_found and not card_slot_found.card_in_slot: 
		#If card slot matches card_type 
		#Card dropped into a empty card slot 
		if card_being_dragged.card_type == card_slot_found.card_slot_type: 
			#Card dropped into correct type of slot 
			if card_being_dragged.card_type == "memory":
				if played_memories_this_turn:
					player_hand_reference.add_card_to_hand(card_being_dragged, DEFAULT_CARD_MOVE_SPEED) 
					card_being_dragged = null 
					return 
				
				#Check the amount of trust the player has. 
				if TrustManager.get_trust() < card_being_dragged.trust_cost:
					# Not enough trust - return card to hand
					$"../ErrorMessage".show_trust_error(card_being_dragged.trust_cost)
					player_hand_reference.add_card_to_hand(card_being_dragged, DEFAULT_CARD_MOVE_SPEED)
					card_being_dragged = null
					return
					
				TrustManager.spend_trust(card_being_dragged.trust_cost)
				
			#Card dropped into card slot 
			#played_memories_this_turn = true ## this ensures only 1 card is played per turn. 
			card_being_dragged.scale = Vector2(CARD_SMALLER_SCALE, CARD_SMALLER_SCALE) ##
			card_being_dragged.z_index = -1 
			is_hovering_on_card = false
			card_being_dragged.card_slot_card_is_in = card_slot_found ##
			player_hand_reference.remove_card_from_hand(card_being_dragged)
			#print("Card slot global position: ", card_slot_found.global_position)
			#print("Card current position: ", card_being_dragged.global_position)
			card_being_dragged.global_position = card_slot_found.global_position
			#card_being_dragged.get_node("Area2D/CollisionShape2D").disabled = true 
			card_slot_found.card_in_slot = true 
			#card_slot_found.get_node("Area2D/CollisionShape2D").disabled = true 
			
			if card_being_dragged.card_type == "memory": 
				$"../BattleManager".player_cards_on_battlefield.append(card_being_dragged)
			
			if card_being_dragged.ability_script: 
				played_event_card(card_being_dragged, "card_placed")
			
			card_being_dragged = null 
			return 
	player_hand_reference.add_card_to_hand(card_being_dragged, DEFAULT_CARD_MOVE_SPEED) 
	card_being_dragged = null 



func unselect_selected_memories(): 
	if selected_memory: 
		selected_memory.global_position.y += 20 
		selected_memory = null 

func raycast_check_for_card_slot(): 
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true 
	parameters.collision_mask = COLLISION_MASK_CARD_SLOT 
	var result = space_state.intersect_point(parameters)
	if result.size() > 0: 
		#print("Raycast slot result:", result)
		return result[0].collider.get_parent()
	return null

func raycast_check_for_menu(): 
	print("raycast check for menu")

func raycast_check_for_play_area() -> bool :
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true 
	parameters.collision_mask = COLLISION_MASK_EVENT_PLAY_AREA
	var result = space_state.intersect_point(parameters)
	return result.size() > 0

func raycast_check_for_card(): 
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true 
	parameters.collision_mask = COLLISION_MASK_CARD
	var result = space_state.intersect_point(parameters)
	if result.size() > 0: 
		#print(result[0].collider.get_parent())
		#print("Raycast slot result:", result)
		return get_card_with_highest_z_index(result)
	return null

func get_card_with_highest_z_index(cards): 
	#Assume first card in cards array has the highest z_index 
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index
	#Loop through rest of card
	for i in range(1, cards.size()): 
		var current_card = cards[i].collider.get_parent()
		if current_card.z_index > highest_z_index: 
			highest_z_card = current_card 
			highest_z_index = current_card.z_index 
	return highest_z_card 


func connect_card_signals(card):
	#print("card connecting....")
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)
	#print("card connected successfully")

func on_hovered_over_card(card): 
	if card.card_slot_card_is_in:
		return  
	if !is_hovering_on_card:
		is_hovering_on_card = true 
		highlight_card(card, true)

func on_hovered_off_card(card): 
	if !card.defeated:
		#Check if card is NOT in a card slot and NOT being dragged
		if !card.card_slot_card_is_in && !card_being_dragged:
		#if !card_being_dragged:
			highlight_card(card, false)
			#Check if hovered off card straight onto another card 
			var new_card_hovered = raycast_check_for_card()
			if new_card_hovered: 
				highlight_card(new_card_hovered, true)
			else: 
				is_hovering_on_card = false

func highlight_card(card, hovered): 
	#if card.card_slot_card_is_in: 
		#print(card.card_slot_card_is_in)
		#return 
	if hovered: 
		card.scale = Vector2(CARD_BIGGER_SCALE, CARD_BIGGER_SCALE)
		card.z_index = 2 
	else: 
		card.scale = Vector2(DEFAULT_CARD_SCALE, DEFAULT_CARD_SCALE)
		card.z_index = 1
		

func on_left_click_released(): 
	#print("card manager released")
	#if the card played is an event card, then upon release, do the ability effect on all opponent cards before turn ends 
	# Check if there's actually a card being dragged first
	if card_being_dragged: 
		#call parse method in deck to get the card type 
		var card_type = card_being_dragged.card_type 
		
		#if card_type is "event", then allow the card to be played on the field without needing a card_slot 
		
		if card_type == "event": 
			# Check if card is over the play area first
			if not raycast_check_for_play_area():  
				player_hand_reference.add_card_to_hand(card_being_dragged, DEFAULT_CARD_MOVE_SPEED) 
				card_being_dragged = null 
				return 
			#need to play card.... as in, needs to have animation to know card has been played 
			
			
			#remove card from player hand 
			player_hand_reference.remove_card_from_hand(card_being_dragged)
			#card is still where player let go
			card_being_dragged.get_node("Area2D/CollisionShape2D").disabled = true 
			
			
			#show a bright flash typa animation to show card has been played  
			
			
			#will automatically play card effect n destroy it
			
			
			played_event_card(card_being_dragged, TRIGGER_EVENT_CARD_PLACED)
			card_being_dragged = null 
			return 
			
		elif card_type == "memory": 
			finish_drag()


func reset_played_memories(): 
	played_memories_this_turn = false

func played_event_card(card, trigger_event): 
	card.ability_script.trigger_ability($"../BattleManager", card, $"../InputManager", trigger_event)


func is_card_over_deck() -> bool:
	var deck_node = $"../Deck"
	var mouse_pos = get_global_mouse_position()
	
	# Check if mouse is within deck's area (adjust the area as needed)
	var deck_rect = Rect2(
		deck_node.global_position - Vector2(75, 100),  # Adjust size as needed
		Vector2(200, 350)  # Adjust size as needed
	)
	
	return deck_rect.has_point(mouse_pos)
