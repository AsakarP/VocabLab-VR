class_name CollectibleItem extends Node3D

@onready var pickable_object = $PickableObject

@export var task_board: Node3D
@export var item_name: String

@export var confirmation_label: Label3D 

# States
var start_transform: Transform3D
var active_controller: XRController3D = null
var is_awaiting_confirmation: bool = false

# Double-click variables
var click_count: int = 0
var time_since_last_click: float = 0.0
var double_click_window: float = 0.5 # Seconds allowed between "grabs"

func _ready():
	# Label off
	if confirmation_label:
		confirmation_label.visible = false
	
	# Store the original position
	start_transform = pickable_object.global_transform
	
	# Connect signals
	pickable_object.connect("picked_up", _on_picked_up)

func _process(delta):
	# Manage the double-click timeout timer
	if click_count > 0 and not is_awaiting_confirmation:
		time_since_last_click += delta
		if time_since_last_click > double_click_window:
			click_count = 0 # Reset if they wait too long between clicks

func _on_picked_up(_pickable):
	# Figure out which controller just grabbed it before dropping it
	var controller = pickable_object.get_picked_up_by_controller()
	if controller:
		active_controller = controller
		
	# Immediately drop the object so it doesn't stick to the hand
	pickable_object.drop()
	pickable_object.global_transform = start_transform
	
	# Force it to stop moving
	if pickable_object is RigidBody3D:
		pickable_object.linear_velocity = Vector3.ZERO
		pickable_object.angular_velocity = Vector3.ZERO

	# If the prompt is already open, ignore further grabs
	if is_awaiting_confirmation:
		return
	
	# Register the "click"
	if click_count == 0:
		click_count = 1
		time_since_last_click = 0.0
	elif click_count == 1 and time_since_last_click <= double_click_window:
		# Double click registered!
		click_count = 0
		_show_prompt()

# UI & Confirmation Logic
func _show_prompt():
	is_awaiting_confirmation = true
	if confirmation_label:
		confirmation_label.text = "Pilih objek?\n[A] Pilih | [B] Batal"
		confirmation_label.visible = true
	
	# Listen to the controller that triggered the prompt for A/B presses
	if active_controller and not active_controller.button_pressed.is_connected(_on_button_pressed):
		active_controller.button_pressed.connect(_on_button_pressed)

func _on_button_pressed(button_name: String):
	if is_awaiting_confirmation:
		if button_name == "ax_button":
			_accept_object()
		elif button_name == "by_button":
			_cancel_prompt()

func _cancel_prompt():
	is_awaiting_confirmation = false
	click_count = 0
	if confirmation_label:
		confirmation_label.visible = false
	
	# Stop listening to the buttons
	if active_controller and active_controller.button_pressed.is_connected(_on_button_pressed):
		active_controller.button_pressed.disconnect(_on_button_pressed)
	active_controller = null

func _accept_object():
	_cancel_prompt()
	
	# Task Board Logic
	if task_board:
		var is_correct = task_board.check_submission(item_name)
		if is_correct:
			# Hide object if correct
			collect_success()
		else:
			# Reset position if wrong
			reset_position()

# Reset/Success Logic
func collect_success():
	if pickable_object.has_method("drop") and pickable_object.is_picked_up():
		pickable_object.drop()
	
	visible = false
	
	process_mode = Node.PROCESS_MODE_DISABLED

func reset_item():
	process_mode = Node.PROCESS_MODE_INHERIT
	
	visible = true
	
	reset_position()
	
func reset_position():
	# Safeguard in case object sticks to hand
	if pickable_object.is_picked_up():
		pickable_object.drop()
	
	# Teleport back to start
	pickable_object.global_transform = start_transform
	
	# Stop the physics
	if pickable_object is RigidBody3D:
		pickable_object.linear_velocity = Vector3.ZERO
		pickable_object.angular_velocity = Vector3.ZERO

func pointer_event(event: XRToolsPointerEvent) -> void:
	# 1. FIRST: Count the hit the exact millisecond the laser sweeps over the object
	if event.event_type == XRToolsPointerEvent.Type.ENTERED:
		
		# Search the entire game world for any node in the "analytics" group
		var managers = get_tree().get_nodes_in_group("analytics")
		
		# If it found at least one node, tell the first one it found to count the hit!
		if managers.size() > 0:
			var game_manager = managers[0]
			if game_manager.has_method("register_raycast_hit"):
				game_manager.register_raycast_hit()
			
	# 2. SECOND: Forward the event up to the parent to handle your double-click grab prompt
	var parent = get_parent()
	if parent.has_method("pointer_event"):
		parent.pointer_event(event)
