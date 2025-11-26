extends Node3D

@export var spawn_points_container: Node3D
@export var objects_container: Node3D

func _ready() -> void:
	shuffle_objects_to_points()

func shuffle_objects_to_points():
	var available_points = spawn_points_container.get_children()
	var objects = objects_container.get_children()
	
	# Shuffle the points, pick random ones
	available_points.shuffle()
	
	# Loop through objects
	for i in range(objects.size()):
		if i >= available_points.size():
			break # Stop if run out of spawn points
			
		var object = objects[i]
		var point = available_points[i]
		
		# Move object to the marker's position
		object.global_transform = point.global_transform
		
		# Update the "Home" position for your reset mechanic
		if "start_transform" in object:
			object.start_transform = object.global_transform
