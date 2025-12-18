extends Area3D

@export_file("*.tscn") var target_scene : String

# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(_body):
	# Skip if no target scene set
	if not target_scene or target_scene == "":
		return
	
	# Find the XRToolsSceneBase
	var scene_base : XRToolsSceneBase = XRTools.find_xr_ancestor(self, "*", "XRToolsSceneBase")
	if not scene_base:
		return
	
	# Start loading the target scene
	scene_base.load_scene(target_scene)
