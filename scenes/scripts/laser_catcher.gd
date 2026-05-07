extends Area3D

# The XR Tools laser hits this invisible Area3D first and triggers this function
func pointer_event(event: XRToolsPointerEvent) -> void:
	print("[LaserCatcher] Hit by laser! Forwarding to CollectibleItem...")
	
	# Pass the event up to your main script
	var parent = get_parent()
	if parent.has_method("pointer_event"):
		parent.pointer_event(event)
