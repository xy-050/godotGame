extends AnimatedSprite2D

var opponent_data: OpponentData

func setup_opponent(data: OpponentData):
	opponent_data = data
	
	# If you're using AnimatedSprite2D with animations
	if data.has("idle_animation"):
		play(data.idle_animation)
