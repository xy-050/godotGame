class_name NotificationUI extends Control 

var notification_queue : Array = []
var is_ready := false

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var title_label: Label = $titleLabel
@onready var message_label: Label = $messageLabel

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	animation_player.animation_finished.connect(notification_animation_finish)
	is_ready = true 
	_try_display_notification()
	print("Quest Notification")

func display_notification() -> void: 
	var notification =  notification_queue.pop_front()
	if notification == null: 
		return 
	title_label.text = notification.title 
	message_label.text = notification.message 
	animation_player.play("notification appear") 
	

func add_notification_to_queue(_title: String, _message: String) -> void: 
	notification_queue.append({title = _title, message = _message})
	if is_ready: 
		call_deferred("_try_display_notification")

func notification_animation_finish(animation_name: String) -> void:
	print("animation started")
	display_notification()
	print("animation is finished")

#if we already have a notif display 
func _try_display_notification() -> void:
	if not is_ready:
		return
	if animation_player.is_playing():
		return
	display_notification()
