#TODO: CHANGE THE SPRITE 2D TO ANIMATED SPRITE 2D FOR CARD N SWITCH THE CODE YIPEEPPEE
# ALSO FIX THE IMG SCALING ISSUE ROOOOOOOOO
#ALso also, fix the draw deck issue, should be allowed to draw 2 cards from each deck

extends Node2D

const CARD_SCENE_PATH = "res://scenes/Battle/card.tscn"
const CARD_DRAW_SPEED = 0.2
const STARTING_HAND_SIZE = 2
const DRAW_CARD_AMT = 2 

var player_deck = ['DOL_Happy', 'DBL_Happy', 'DAL_Happy', 'Fear_Happy', 'Trismegistus_Bomb']
var card_database_reference  
var drawn_card_this_turn = false 
var count_num_cards_drawn = 0 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_deck.shuffle()
	$RichTextLabel.text = str(player_deck.size())
	card_database_reference = preload("res://scripts/Battle/CardDB.gd")
	#print($Area2D.collision_mask) # Replace with function body.
	for i in range(STARTING_HAND_SIZE): 
		draw_card()
		drawn_card_this_turn = false 
	drawn_card_this_turn = true 


func draw_card(): 
	if drawn_card_this_turn: 
		count_num_cards_drawn += 1 
		print(count_num_cards_drawn)
		return
	
	if drawn_card_this_turn && count_num_cards_drawn == DRAW_CARD_AMT: ## modified 
		drawn_card_this_turn = true
	
	var card_drawn_name = player_deck[0]
	
	player_deck.erase(card_drawn_name)
	
	#If player draws the last card in the deck, disable the deck 
	if player_deck.size() == 0: 
		$Area2D/CollisionShape2D.disabled = true 
		$AnimatedSprite2D.visible = false 
		$RichTextLabel.visible = false  

	#print("draw card")
	$RichTextLabel.text = str(player_deck.size())
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	new_card.card_name = card_drawn_name
	var card_image_path = str("res://assets/cards/card_img/" + card_drawn_name + ".png")
	##COME BACK N FIX THE TEXTURE ISSUE -> MAKE IT ANIMATED ROOOOOOOOO 
	var front = new_card.get_node("CardFront")
	front.texture = load(card_image_path)
	
	new_card.card_type = card_database_reference.CARDS[card_drawn_name][3]
	var card_type = new_card.card_type
	
	
	if card_type == "memory": 
		#create var 
		new_card.attack = card_database_reference.CARDS[card_drawn_name][0]
		new_card.hp = card_database_reference.CARDS[card_drawn_name][1]
		new_card.trust_cost = card_database_reference.CARDS[card_drawn_name][2]
		
		##COME BACK N FIX SCALING ISSUE -> MAKE IMAGES SMALLER OR THIS BOI WILL CRASH ROOOOOO
		new_card.get_node("Attack").text += str(new_card.attack)
		new_card.get_node("HP").text += str(new_card.hp)
		new_card.get_node("Trust_cost").text += str(new_card.trust_cost)
		
		
	elif card_type == "event": 
		new_card.get_node("Attack").visible = false
		new_card.get_node("HP").visible = false
		new_card.get_node("Trust_cost").visible = false
	
	var new_card_ability_script_path = card_database_reference.CARDS[card_drawn_name][5]
	
	#print(new_card_ability_script_path)
	
	if new_card_ability_script_path: 
		new_card.ability_script = load(new_card_ability_script_path).new()
		new_card.get_node("Ability").text = card_database_reference.CARDS[card_drawn_name][4]
		print(new_card.get_node("Ability").text)
	else: 
		new_card.get_node("Ability").visible = false
	
	$"../CardManager".add_child(new_card)
	new_card.name = "Card"
	$"../PlayerHand".add_card_to_hand(new_card, CARD_DRAW_SPEED)
	#new_card.get_node("AnimationPlayer").call_deferred("play", "card_flip")
	new_card.get_node("cardFlip").play("card_flip")

func reset_draw(): 
	drawn_card_this_turn = false 
	
