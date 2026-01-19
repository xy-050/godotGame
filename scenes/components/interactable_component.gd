#TODO: HANDLE THE BG ERROR APPEARING BEHIND OPEN WORLD 
# _UNHANDLED_INPUT LOGIC FLAWED
#TRANSITION SMOOTHLY BACK TO MAIN GAME HAVENT TESTED YET 
class_name InteractableComponent 
extends Area2D

signal interactable_activated 
signal interactable_deactivated 


func _on_body_entered(body: Node2D) -> void:
	interactable_activated.emit() 


func _on_body_exited(body: Node2D) -> void:
	interactable_deactivated.emit() 
