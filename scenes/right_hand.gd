extends XRController3D
var activePointedObject = null

func _ready():
	connect("button_pressed", btnPressedOnLeftCtrl)
	connect("button_pressed", btnReleasedOnLeftCtrl)
	
func _physics_process(delta):
	if $RayCast3D.is_colliding():
		var c = $RayCast3D.get_collider()
		activePointedObject = c
	else:
		activePointedObject = null
		
func btnPressedOnLeftCtrl(name):
	print(name)
	if name == "grip_click":
		if activePointedObject:
			print("button pressed")
			
func btnReleasedOnLeftCtrl(name):
	if name == "grip_click":
		pass
