class_name CollectibleItem extends Node3D

@onready var pickable_object = $PickableObject
@onready var highlight_light: OmniLight3D = $PickableObject/HighlightLight

@export var task_board: Node3D
@export var item_name: String

# Settings
var respawn_time: float = 5.0

# States
var respawn_tween: Tween
var start_transform: Transform3D

func _ready():
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
		
	if task_board:
		var is_correct = task_board.check_submission(item_name)
		
		if is_correct:
			# Hide object if correct
			queue_free()
		
		else:
			# Reset position if wrong
			reset_position()

func _on_dropped(_pickable):
	# Start countdown to respawn
	start_respawn_timer()

func _on_highlight_updated(_pickable, enable: bool):
	if enable:
		if highlight_light: highlight_light.visible = true
	else:
		if not pickable_object.is_picked_up():
			if highlight_light: highlight_light.visible = false

func collect_success():
	if pickable_object.has_method("drop") and pickable_object.is_picked_up():
		pickable_object.drop()
	
	if highlight_light: highlight_light.visible = false
	
	visible = false
	
	process_mode = Node.PROCESS_MODE_DISABLED

func reset_item():
	process_mode = Node.PROCESS_MODE_INHERIT
	
	visible = true
	
	reset_position()

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
	# Prevent reset twice
	if respawn_tween:
		respawn_tween.kill()
		
	if pickable_object.is_picked_up():
		pickable_object.drop()
	
	# Teleport back to start
	pickable_object.global_transform = start_transform
	
	# Stop the physics
	if pickable_object is RigidBody3D:
		pickable_object.linear_velocity = Vector3.ZERO
		pickable_object.angular_velocity = Vector3.ZERO
