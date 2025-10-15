extends XRController3D


# Called when the node enters the scene tree for the first time.
func _ready():
	connect("button_pressed", leftCtrler)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func leftCtrler(name):
	print(name)
