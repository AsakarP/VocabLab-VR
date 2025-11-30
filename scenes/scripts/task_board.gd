extends Node3D

@onready var label_3d = $Label3D

@export var master_item_list: Array[String] = []
@export var current_student_id: String = "Subject_001"
@export var item_container: Node3D

var current_queue: Array[String] = []
var current_idx: int = 0
var score: int = 0
var game_active: bool = false
var time: float = 0.0
var time_limit: float = 600.0

# Runs every single frame
func _process(delta):
	if game_active:
		time -= delta
		if time <= 0:
			time = 0
			end_game_timeout()
		else:
			update_board_disp()

# Starts new round
func start_new_round():
	if game_active:
		return
		
	if master_item_list.is_empty():
		printerr("Master List is Empty!")
		label_3d.text = "List is Empty!"
		label_3d.modulate = Color.RED
		return
		
	if item_container:
		for item in item_container.get_children():
			if item.has_method("reset_item"):
				item.reset_item()
	
	current_queue = master_item_list.duplicate()
	current_queue.shuffle()
	
	score = 0
	current_idx = 0
	
	time = time_limit
	game_active = true
	
	update_board_disp()
	
func update_board_disp():
	var time_str = format_seconds(time)
	
	if current_idx < current_queue.size():
		var target = current_queue[current_idx]
		label_3d.text = "Find: %s\nScore: %d\nTime Left: %s" % [target, score, time_str]

func end_game_timeout():
	game_active = false
	
	label_3d.text = "Time's Up!\nFinal Score: %d" % score
	label_3d.modulate = Color.RED

func end_game_win():
	game_active = false
	
	# Capture visible time as a number
	var visible_time_left_sec = int(time)
	
	# Time taken
	var time_taken_seconds = time_limit - visible_time_left_sec
	
	# Format strings
	var time_taken_str = format_seconds(time_taken_seconds)
	var time_left_str = format_seconds(visible_time_left_sec)
	
	label_3d.text = "All Tasks Done!\nFinal Score: %d\nCompleted In: %s\nTime Left: %s" % [score, time_taken_str, time_left_str]
	label_3d.modulate = Color.GREEN

func check_submission(submitted_item_name: String) -> bool:
	if !game_active or current_idx >= current_queue.size():
		return false
		
	var tween = create_tween()
	
	if submitted_item_name == current_queue[current_idx]:
		# Correct object
		score += 1
		current_idx += 1
		
		label_3d.modulate = Color.GREEN
		tween.tween_property(label_3d, "modulate", Color.WHITE, 1.0)
		
		if current_idx >= current_queue.size():
			end_game_win()
		else:
			update_board_disp()
			
		return true
	else:
		# Incorrect object
		score -= 1
		update_board_disp()
		
		label_3d.modulate = Color.RED
		tween.tween_property(label_3d, "modulate", Color.WHITE, 1.0)
		
		return false

func format_seconds(amount: float) -> String:
	var clean_time = max(0.0, amount)
	var minutes = int(clean_time / 60)
	var seconds = int(clean_time) % 60
	
	return "%02d:%02d" % [minutes,seconds]

# If button pressed start new round
func _on_interactable_area_button_button_pressed(_button):
	start_new_round()
