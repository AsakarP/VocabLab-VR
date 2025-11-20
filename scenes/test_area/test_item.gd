class_name CollectibleItem extends Node3D

@onready var pickable_object = $PickableObject

@export var item_name: String

# Settings
var respawn_time: float = 5.0

# States
var respawn_tween: Tween
var start_transform: Transform3D

func _ready():
	# Store the original position
	start_transform = pickable_object.global_transform
	
	# Connect signals
	pickable_object.connect("picked_up", _on_picked_up)
	pickable_object.connect("dropped", _on_dropped)

func _on_picked_up(_pickable):
	# If picked up, cancel any pending respawn
	if respawn_tween:
		respawn_tween.kill()

func _on_dropped(_pickable):
	# Start countdown to respawn
	start_respawn_timer()
	
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
