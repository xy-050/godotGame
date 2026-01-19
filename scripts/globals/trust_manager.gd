extends Node

signal trust_changed(new_value, old_value)
signal trust_depleted()

const MAX_TRUST = 125
const STARTING_TRUST = 50

var current_trust: int = STARTING_TRUST

func spend_trust(amount: int) -> bool:
	if amount > current_trust:
		return false  # Not enough trust
	
	var old_trust = current_trust
	current_trust -= amount
	trust_changed.emit(current_trust, old_trust)
	
	if current_trust <= 0:
		trust_depleted.emit()
	
	return true

func gain_trust(amount: int) -> void:
	var old_trust = current_trust
	current_trust = min(current_trust + amount, MAX_TRUST)
	trust_changed.emit(current_trust, old_trust)

func get_trust() -> int:
	return current_trust

# Get chance of creepy events (0.0 to 1.0)
func get_creepy_event_chance() -> float:
	# As trust goes down, creepy chance goes up
	# Trust 50 = 0% chance, Trust 0 = 80% chance
	#return (1.0 - (current_trust / float(MAX_TRUST))) * 0.8
	return 0.0  

# Get intensity multiplier for effects
func get_creepy_intensity() -> float:
	# 0.0 at full trust, 1.0 at zero trust
	#return 1.0 - (current_trust / float(MAX_TRUST))
	return 0.0
