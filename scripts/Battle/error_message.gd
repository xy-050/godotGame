extends Label

func _ready() -> void:
	visible = false
	modulate.a = 1.0

func show_error(message: String, color: Color = Color.RED, duration: float = 2.0) -> void:
	text = message
	modulate = color
	modulate.a = 1.0
	visible = true
	
	# Fade out after duration
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.0).set_delay(duration - 1.0)
	tween.tween_callback(func(): visible = false)

# Optional: Specific helper methods
func show_trust_error(trust_needed: int) -> void:
	show_error("Not enough trust! Need %d" % trust_needed, Color.RED)

func show_success(message: String) -> void:
	show_error(message, Color.GREEN, 1.5)
