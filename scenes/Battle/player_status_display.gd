extends Node2D


func _ready():
	# Connect to the battle manager's signal
	var battle_manager_reference = $"../BattleManager"
	battle_manager_reference.player_damaged.connect(_on_player_damaged)
	
	#click on the frame once 
	

func _on_player_damaged(damage):
	$AnimatedSprite.play("hurt")
	# Wait for the hurt animation to finish, then return to idle
	await $AnimatedSprite.animation_finished
	$AnimatedSprite.play("idle")
