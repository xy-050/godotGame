extends Control

@onready var progress_bar = $PlayerTrustBar
@onready var label = $PlayerTrustLevel

func _ready() -> void:
	# Setup progress bar
	progress_bar.max_value = TrustManager.MAX_TRUST
	progress_bar.value = TrustManager.get_trust()
	
	# Connect to changes
	TrustManager.trust_changed.connect(_on_trust_changed)
	
	update_display()

func _on_trust_changed(new_value: int, old_value: int) -> void:
	# Animate bar
	var tween = create_tween()
	tween.tween_property(progress_bar, "value", new_value, 0.3)
	
	# Update label
	update_display()
	
	# Shake effect when trust drops
	if new_value < old_value:
		shake_bar()

func update_display() -> void:
	var current = TrustManager.get_trust()
	#display the current trust value
	label.text = "Trust: " + str(current)

func shake_bar() -> void:
	var original_pos = position
	var tween = create_tween()
	for i in range(3):
		tween.tween_property(self, "position:x", original_pos.x - 5, 0.05)
		tween.tween_property(self, "position:x", original_pos.x + 5, 0.05)
	tween.tween_property(self, "position", original_pos, 0.05)
