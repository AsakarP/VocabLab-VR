extends XROrigin3D

# Grab the pointer directly from your scene tree
@onready var right_pointer = $RightHand/FunctionPointer

func _ready():
	if right_pointer:
		right_pointer.pointing_event.connect(_on_pointer_event)
	else:
		printerr("[Player Tracker] Could not find FunctionPointer on RightHand!")

# This receives the XRToolsPointerEvent variant
func _on_pointer_event(event: Variant):
	# ONLY trigger the exact moment the laser enters the object
	if event.event_type == XRToolsPointerEvent.Type.ENTERED:
		var target = event.target
		
		if target == null:
			return
			
		# Check if the object we hit lives on Layer 3 (Pickable Objects)
		if target is CollisionObject3D and target.get_collision_layer_value(3):
			# Look for the TaskBoard in the current room
			var managers = get_tree().get_nodes_in_group("analytics")
			
			# If a TaskBoard exists (We are in a Testing Room!), count the hit
			if managers.size() > 0:
				var game_manager = managers[0]
				if game_manager.has_method("register_object_detected"):
					game_manager.register_object_detected()
					print("[Player Tracker] Target scanned: ", target.name)
