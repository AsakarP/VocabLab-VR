extends Camera3D

# Sensitivity of the mouse
@export var mouse_sensitivity: float = 0.002
# Speed of movement
@export var move_speed: float = 5.0

func _ready():
	# Hides the mouse cursor so you can look around freely
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	# Handle Mouse Rotation
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		rotate_object_local(Vector3(1, 0, 0), -event.relative.y * mouse_sensitivity)

func _process(delta):
	var input_dir = Vector3.ZERO

	# Handle WASD Movement
	if Input.is_key_pressed(KEY_W):
		input_dir -= transform.basis.z
	if Input.is_key_pressed(KEY_S):
		input_dir += transform.basis.z
	if Input.is_key_pressed(KEY_A):
		input_dir -= transform.basis.x
	if Input.is_key_pressed(KEY_D):
		input_dir += transform.basis.x
	
	# Handle Up/Down (Q and E)
	if Input.is_key_pressed(KEY_E):
		input_dir.y += 1
	if Input.is_key_pressed(KEY_Q):
		input_dir.y -= 1

	# Apply movement
	position += input_dir.normalized() * move_speed * delta

	# ESC to free the mouse cursor
	if Input.is_key_pressed(KEY_ESCAPE):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
