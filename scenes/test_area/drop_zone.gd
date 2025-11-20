extends Area3D

@export var task_board: Node3D
@onready var mesh_instance_3d = $MeshInstance3D

func _ready():
	mesh_instance_3d.visible = false

func _on_body_entered(body):
	var item_node = null
	
	if body is CollectibleItem:
		item_node = body
		
	elif body.get_parent() is CollectibleItem:
		item_node = body.get_parent()
	
	if item_node:
		var is_correct = task_board.check_submission(item_node.item_name)
		
		if is_correct:
			item_node.queue_free()
		else:
			pass

func _on_interactable_area_button_button_pressed(_button):
	mesh_instance_3d.visible = true
