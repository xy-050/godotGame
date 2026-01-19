extends Node2D
@onready var sprite = $Sprite2D


func _ready() -> void:
	self.modulate.a = 0
	pass 

func change_character(character_name : Character.Name, expression: String): 
	var expressions = Character.CHARACTER_DETAILS[character_name]["expressions"]
	if expression == "" or not expressions.has(expression):
		expression = "normal" # default
	if expressions.has(expression) and expressions[expression] != null:
		sprite.texture = expressions[expression]
		print("sprite appear")
	else:
		sprite.texture = null # hide sprite if texture is missing
		
	#fade in character sprite 
	if self.modulate.a ==0: 
		create_tween().tween_property(self, "modulate:a", 1.0, 0.3)


#	var expressions = Character.CHARACTER_DETAILS[character_name]["expressions"]
#	if expressions.has(expression): 
#		sprite.texture = expressions[expression]
	
#func reset_to_idle(): 
#	var last_expression = sprite.texture 
#	if last_expression and not last_expression.equals("normal")
	#HANDLE LOGIC 
