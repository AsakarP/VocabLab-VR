extends Node3D

@onready var pickable_object = $PickableObject
@onready var text = $PickableObject/Label3D
@onready var highlight_light: OmniLight3D = $PickableObject/HighlightLight
@onready var sound_player = $AudioStreamPlayer3D

@export var sound_pickup: AudioStream

# Settings
var fade_duration: float = 1.0
var respawn_time: float = 5.0

# States
var current_tween: Tween
var respawn_tween: Tween
var start_transform: Transform3D

func _ready():
	# Initial state
	text.visible = false
	text.modulate.a = 0.0
	
	# Highlight light off
	highlight_light.visible = false
	
	# Store the original position
	start_transform = pickable_object.global_transform
	
	# Connect signals
	pickable_object.connect("picked_up", _on_picked_up)
	pickable_object.connect("dropped", _on_dropped)
	
	if pickable_object.has_signal("highlight_updated"):
		pickable_object.connect("highlight_updated", _on_highlight_updated)

func _on_picked_up(_pickable):
	# If picked up, cancel any pending respawn
	if respawn_tween:
		respawn_tween.kill()
	# Fade in
	animate_text(true)
	play_sfx(sound_pickup)

func _on_dropped(_pickable):
	# Fade out
	animate_text(false)
	
	# Start countdown to respawn
	start_respawn_timer()
	
func play_sfx(stream: AudioStream):
	if sound_player and stream:
		sound_player.stream = stream
		sound_player.play()

func _on_highlight_updated(_pickable, enable: bool):
	if enable:
		if highlight_light: highlight_light.visible = true
	else:
		if not pickable_object.is_picked_up():
			if highlight_light: highlight_light.visible = false

func start_respawn_timer():
	# Kill existing timer if one is running
	if respawn_tween:
		respawn_tween.kill()
	
	respawn_tween = create_tween()
	# Wait for respawn_time seconds
	respawn_tween.tween_interval(respawn_time)
	# Call the reset function
	respawn_tween.tween_callback(reset_position)
	
func reset_position():
	# Teleport back to start
	pickable_object.global_transform = start_transform
	
	# Stop the physics
	if pickable_object is RigidBody3D:
		pickable_object.linear_velocity = Vector3.ZERO
		pickable_object.angular_velocity = Vector3.ZERO

func animate_text(show_text: bool):
	# Kill active animation to prevent glitches if dropped immediately after pickup
	if current_tween:
		current_tween.kill()
	
	current_tween = create_tween()
	
	if show_text:
		text.visible = true
		# Tween alpha to opaque
		current_tween.tween_property(text, "modulate:a", 1.0, fade_duration)
	else:
		# Tween alpha to transparent
		current_tween.tween_property(text, "modulate:a", 0.0, fade_duration)
		# Turn off visibility only after the fade finishes
		current_tween.tween_callback(func(): text.visible = false)
