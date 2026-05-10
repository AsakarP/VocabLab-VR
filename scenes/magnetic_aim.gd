extends Area3D

@onready var controller: XRController3D = get_parent()
var xr_pointer: Node3D = null

# Keep track of physical bodies inside our assist cone
var nearby_targets: Array[Node3D] = []

func _ready():
	body_entered.connect(_on_target_body_entered)
	body_exited.connect(_on_target_body_exited)
	call_deferred("_find_xr_pointer")

func _find_xr_pointer():
	for child in controller.get_children():
		if "FunctionPointer" in child.name or child.has_method("pointer_event"):
			xr_pointer = child
			print("[AimAssist] Successfully linked to: ", xr_pointer.name)
			break

func _process(_delta):
	if not xr_pointer or nearby_targets.is_empty():
		return
		
	# Find the closest target inside our assist cone
	var best_target = _get_closest_target_to_aim()
	if best_target:
		_snap_pointer_to_target(best_target)

# --- FIXED: Removed the has_method() filter entirely! ---
func _on_target_body_entered(body: Node3D):
	# Since your Mask strictly filters for Layer 3, anything entering is guaranteed to be a target
	if body not in nearby_targets:
		nearby_targets.append(body)
		print("[AimAssist] Magnetic target locked: ", body.name)

func _on_target_body_exited(body: Node3D):
	if body in nearby_targets:
		nearby_targets.erase(body)
		print("[AimAssist] Target left cone.")
	
	# If we just left the last object, reset the pointer rotation to straight forward
	if nearby_targets.is_empty() and xr_pointer:
		xr_pointer.transform.basis = Basis() # Resets rotation to default

func _get_closest_target_to_aim() -> Node3D:
	var best_target: Node3D = null
	var highest_dot: float = -1.0
	
	var hand_pos = global_position
	var aim_dir = -global_transform.basis.z.normalized() # VR forward is -Z
	
	for target in nearby_targets:
		if not is_instance_valid(target):
			continue
			
		var dir_to_target = (target.global_position - hand_pos).normalized()
		var dot = aim_dir.dot(dir_to_target)
		
		if dot > highest_dot:
			highest_dot = dot
			best_target = target
			
	return best_target

func _snap_pointer_to_target(target: Node3D):
	# Force the FunctionPointer to physically tilt and point at the target's origin
	xr_pointer.look_at(target.global_position, Vector3.UP)
