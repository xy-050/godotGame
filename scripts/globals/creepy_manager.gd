## CreepyEventManager.gd - Add this as an Autoload singleton too
#extends Node
#
## Event types
#enum CreepyEvent {
	#PHANTOM_SCREAM,
	#FLASH_FACE,
	#FOG_APPEAR,
	#SCREEN_SHAKE,
	#WHISPERS,
	#SHADOW_FIGURE,
	#GLITCH_EFFECT
#}
#
## Timers
#var event_check_timer: Timer
#var event_cooldown_timer: Timer
#
## Settings
#const MIN_EVENT_INTERVAL = 5.0  # Check every 5 seconds
#const EVENT_COOLDOWN = 3.0  # Minimum time between events
#
#var can_trigger_event = true
#
#func _ready() -> void:
	#setup_timers()
#
#func setup_timers() -> void:
	## Main event check timer
	#event_check_timer = Timer.new()
	#event_check_timer.wait_time = MIN_EVENT_INTERVAL
	#event_check_timer.autostart = true
	#event_check_timer.timeout.connect(_check_for_event)
	#add_child(event_check_timer)
	#
	## Cooldown timer
	#event_cooldown_timer = Timer.new()
	#event_cooldown_timer.one_shot = true
	#event_cooldown_timer.timeout.connect(_on_cooldown_finished)
	#add_child(event_cooldown_timer)
#
#func _check_for_event() -> void:
	#if not can_trigger_event:
		#return
	#
	#var chance = TrustManager.get_creepy_event_chance()
	#var roll = randf()
	#
	#if roll < chance:
		#trigger_random_event()
#
#func trigger_random_event() -> void:
	#var event = CreepyEvent.values().pick_random()
	#execute_event(event)
	#
	## Start cooldown
	#can_trigger_event = false
	#event_cooldown_timer.start(EVENT_COOLDOWN)
#
#func execute_event(event: CreepyEvent) -> void:
	#var intensity = TrustManager.get_creepy_intensity()
	#
	#match event:
		#CreepyEvent.PHANTOM_SCREAM:
			#play_phantom_scream(intensity)
		#
		#CreepyEvent.FLASH_FACE:
			#flash_creepy_face(intensity)
		#
		#CreepyEvent.FOG_APPEAR:
			#spawn_fog(intensity)
		#
		#CreepyEvent.SCREEN_SHAKE:
			#shake_screen(intensity)
		#
		#CreepyEvent.WHISPERS:
			#play_whispers(intensity)
		#
		#CreepyEvent.SHADOW_FIGURE:
			#spawn_shadow_figure(intensity)
		#
		#CreepyEvent.GLITCH_EFFECT:
			#trigger_glitch(intensity)
#
## Event implementations
#func play_phantom_scream(intensity: float) -> void:
	#print("🔊 Phantom scream! Intensity: ", intensity)
	## Play audio with volume based on intensity
	#var scream = AudioStreamPlayer.new()
	#add_child(scream)
	#scream.stream = preload("res://audio/scream.ogg")  # Your audio file
	#scream.volume_db = lerp(-20.0, 0.0, intensity)
	#scream.play()
	#await scream.finished
	#scream.queue_free()
#
#func flash_creepy_face(intensity: float) -> void:
	#print("😱 Flashing face! Intensity: ", intensity)
	## You'll need to get reference to the current scene
	#var scene = get_tree().current_scene
	#
	## Create flash overlay
	#var flash = ColorRect.new()
	#scene.add_child(flash)
	#flash.color = Color(1, 1, 1, 0)
	#flash.size = get_viewport().size
	#flash.z_index = 100
	#
	## Add face sprite
	#var face = Sprite2D.new()
	#flash.add_child(face)
	#face.texture = preload("res://assets/creepy_face.png")  # Your image
	#face.position = get_viewport().size / 2
	#face.modulate.a = 0
	#
	## Animate
	#var tween = create_tween()
	#var duration = lerp(0.3, 0.1, intensity)  # Faster at high intensity
	#tween.tween_property(face, "modulate:a", intensity, duration * 0.3)
	#tween.tween_property(face, "modulate:a", 0, duration * 0.7)
	#await tween.finished
	#flash.queue_free()
#
#func spawn_fog(intensity: float) -> void:
	#print("🌫️ Fog appearing! Intensity: ", intensity)
	#var scene = get_tree().current_scene
	#
	## Create fog overlay
	#var fog = ColorRect.new()
	#scene.add_child(fog)
	#fog.color = Color(0.2, 0.2, 0.3, 0)
	#fog.size = get_viewport().size
	#fog.z_index = 50
	#
	## Fade in and out
	#var tween = create_tween()
	#var max_alpha = lerp(0.2, 0.6, intensity)
	#tween.tween_property(fog, "color:a", max_alpha, 2.0)
	#tween.tween_property(fog, "color:a", 0, 3.0)
	#await tween.finished
	#fog.queue_free()
#
#func shake_screen(intensity: float) -> void:
	#print("📳 Screen shaking! Intensity: ", intensity)
	#var camera = get_viewport().get_camera_2d()
	#if not camera:
		#return
	#
	#var original_offset = camera.offset
	#var shake_amount = lerp(5.0, 20.0, intensity)
	#var duration = lerp(0.2, 0.5, intensity)
	#
	#var elapsed = 0.0
	#while elapsed < duration:
		#camera.offset = original_offset + Vector2(
			#randf_range(-shake_amount, shake_amount),
			#randf_range(-shake_amount, shake_amount)
		#)
		#await get_tree().create_timer(0.05).timeout
		#elapsed += 0.05
	#
	#camera.offset = original_offset
#
#func play_whispers(intensity: float) -> void:
	#print("👻 Whispers! Intensity: ", intensity)
	#var whisper = AudioStreamPlayer.new()
	#add_child(whisper)
	#whisper.stream = preload("res://audio/whispers.ogg")  # Your audio
	#whisper.volume_db = lerp(-30.0, -10.0, intensity)
	#whisper.play()
	#await whisper.finished
	#whisper.queue_free()
#
#func spawn_shadow_figure(intensity: float) -> void:
	#print("👤 Shadow figure! Intensity: ", intensity)
	#var scene = get_tree().current_scene
	#
	#var shadow = Sprite2D.new()
	#scene.add_child(shadow)
	#shadow.texture = preload("res://assets/shadow_figure.png")  # Your image
	#shadow.modulate = Color(0, 0, 0, 0)
	#shadow.z_index = 75
	#
	## Random position at edge of screen
	#var viewport_size = get_viewport().size
	#var side = randi() % 4
	#match side:
		#0: shadow.position = Vector2(randf() * viewport_size.x, -50)  # Top
		#1: shadow.position = Vector2(viewport_size.x + 50, randf() * viewport_size.y)  # Right
		#2: shadow.position = Vector2(randf() * viewport_size.x, viewport_size.y + 50)  # Bottom
		#3: shadow.position = Vector2(-50, randf() * viewport_size.y)  # Left
	#
	## Fade in and out
	#var tween = create_tween()
	#var max_alpha = lerp(0.3, 0.7, intensity)
	#tween.tween_property(shadow, "modulate:a", max_alpha, 1.0)
	#tween.tween_property(shadow, "modulate:a", 0, 1.5)
	#await tween.finished
	#shadow.queue_free()
#
#func trigger_glitch(intensity: float) -> void:
	#print("⚡ Glitch effect! Intensity: ", intensity)
	## Apply shader or visual distortion to the viewport
	## This is a placeholder - you'd use a shader for real glitch
	#var scene = get_tree().current_scene
	#
	#for i in range(int(lerp(3, 10, intensity))):
		#scene.modulate = Color(randf(), randf(), randf(), 1.0)
		#await get_tree().create_timer(0.05).timeout
	#
	#scene.modulate = Color(1, 1, 1, 1)
#
#func _on_cooldown_finished() -> void:
	#can_trigger_event = true
#
## Optional: Manually trigger specific events (for testing or scripted moments)
#func force_event(event: CreepyEvent) -> void:
	#execute_event(event)
