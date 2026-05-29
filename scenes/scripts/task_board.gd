extends Node3D

@onready var label_3d: Label3D = $"../../XROrigin3D/XRCamera3D/Label3D"
@onready var sound_player: AudioStreamPlayer3D = $"../../XROrigin3D/XRCamera3D/AudioStreamPlayer3D"
@onready var sprite_3d: Sprite3D = $Sprite3D
@onready var teleport_area: Area3D = $"../TeleportArea"
@onready var push_button: Node3D = $PushButton

@export var tracked_controller: XRController3D 
@export var scene_name_override: String = "Scene 1" # Easy way to label rows in Excel

@export var master_item_list: Array[String] = []
@export var objectsNode: Node3D
@export var sound_correct: AudioStream
@export var sound_incorrect: AudioStream
@export var room_manager: Node3D

var current_queue: Array[String] = []
var current_idx: int = 0
var score: int = 0
var obj: int = 0
var obj_total: int = 0
var game_active: bool = false
var time: float = 0.0
var time_limit: float = 600.0

var error_log: String = ""

# --- NEW ANALYTICS: Tracking Variables ---
var wrong_picks: int = 0
var raycast_hits: int = 0
var controller_distance: float = 0.0
var last_controller_pos: Vector3 = Vector3.ZERO

func _ready():
	print("Checking Autoload: ", SessionData)

# Runs every single frame
func _process(delta):
	if game_active:
		time -= delta
		
		if tracked_controller and tracked_controller.is_inside_tree():
			var current_pos = tracked_controller.global_position
			if last_controller_pos != Vector3.ZERO:
				# Add the distance moved since the last frame (in meters)
				controller_distance += last_controller_pos.distance_to(current_pos)
			last_controller_pos = current_pos
		
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
		
	if room_manager and room_manager.has_method("shuffle_objects_to_points"):
		room_manager.shuffle_objects_to_points()
		
	if objectsNode:
		for item in objectsNode.get_children():
			if item.has_method("reset_item"):
				item.reset_item()
	
	var tween = create_tween()
	tween.kill()
	
	label_3d.modulate = Color.WHITE
	
	current_queue = master_item_list.duplicate()
	current_queue.shuffle()
	
	score = 0
	obj = 0
	obj_total = len(master_item_list)
	current_idx = 0
	error_log = ""
	
	# --- NEW ANALYTICS: Reset all counters for the new round ---
	wrong_picks = 0
	raycast_hits = 0
	controller_distance = 0.0
	
	if tracked_controller and tracked_controller.is_inside_tree():
		last_controller_pos = tracked_controller.global_position
	else:
		last_controller_pos = Vector3.ZERO
	
	time = time_limit
	game_active = true
	
	update_board_disp()
	
	sprite_3d.visible = false
	teleport_area.monitoring = false
	teleport_area.visible = false
	
func update_board_disp():
	var time_str = format_seconds(time)
	
	if current_idx < current_queue.size():
		var target = current_queue[current_idx]
		label_3d.text = "Cari: %s\nObjek: %d/%d\nPoin: %d\nSisa Waktu: %s" % \
		[target, obj, obj_total, score, time_str]

# --- NEW ANALYTICS: Public function for your Raycast/Laser to call ---
func register_object_detected():
	if game_active:
		raycast_hits += 1

func end_game_timeout():
	game_active = false
	
	# --- NEW ANALYTICS: Process final time and save ---
	var time_taken_seconds = time_limit - int(time)
	var time_taken_str = format_seconds(time_taken_seconds)
	save_analytics_to_csv(time_taken_str, "TIMEOUT")
	
	if error_log == "":
		label_3d.text = "Waktu Habis!\nObjek yang teridentifikasi: %d/%d\nPoin Akhir: %d \
		\nSilakan berjalan menuju portal di sudut ruangan\nuntuk melanjutkan ke tahap berikutnya." % \
		[obj, obj_total, score]
		label_3d.modulate = Color.RED
		
		print("*** Summary ***")
		print("Poin Akhir: ",score)
	else:
		label_3d.text = "Waktu Habis!\nObjek yang teridentifikasi: %d/%d\nPoin Akhir: %d\nKesalahan:\n%s \
		\nSilakan berjalan menuju portal di sudut ruangan\nuntuk melanjutkan ke tahap berikutnya." % \
		[obj, obj_total, score, error_log]
		label_3d.modulate = Color.ORANGE
		
		print("*** Summary ***")
		print("Poin Akhir: ",score)
		print("*** Mistakes ***")
		print(error_log)
	
	push_button.visible = false
	push_button.process_mode = Node.PROCESS_MODE_DISABLED
	sprite_3d.visible = false
	teleport_area.monitoring = true
	teleport_area.visible = true

func end_game_win():
	game_active = false
	
	# Stop any lingering tween
	var tween = create_tween()
	tween.kill()
	
	# Capture visible time as a number
	var visible_time_left_sec = int(time)
	
	# Time taken
	var time_taken_seconds = time_limit - visible_time_left_sec
	
	# Format strings
	var time_taken_str = format_seconds(time_taken_seconds)
	var time_left_str = format_seconds(visible_time_left_sec)
	
	# Save to CSV when the player wins
	save_analytics_to_csv(time_taken_str, "WIN")
	
	if error_log == "":
		label_3d.text = "Semua Objek Teridentifikasi! (%d/%d)\nPoin Akhir: %d\nDiselesaikan dalam: %s\n \
		Sisa Waktu: %s\nTidak ada Kesalahan, Hebat!\nSilakan berjalan menuju portal di sudut ruangan\
		\nuntuk melanjutkan ke tahap berikutnya." % [obj, obj_total, score, time_taken_str, time_left_str]
		label_3d.modulate = Color.GREEN
		
		print("*** Summary ***")
		print("Poin Akhir: ",score)
		print("Time Taken: ",time_taken_str)
		print("Time Left: ",time_left_str)
	else:
		label_3d.text = "Semua Objek Teridentifikasi! (%d/%d)\nPoin Akhir: %d\nDiselesaikan dalam: %s\n \
		Sisa Waktu: %s\nKesalahan:\n%s\nSilakan berjalan menuju portal di sudut ruangan\nuntuk melanjutkan \
		ke tahap berikutnya." % [obj, obj_total, score, time_taken_str, time_left_str, error_log]
		label_3d.modulate = Color.ORANGE
		
		print("*** Summary ***")
		print("Poin Akhir: ",score)
		print("Time Taken: ",time_taken_str)
		print("Time Left: ",time_left_str)
		print("*** Mistakes ***")
		print(error_log)
	
	push_button.visible = false
	push_button.process_mode = Node.PROCESS_MODE_DISABLED
	sprite_3d.visible = false
	teleport_area.monitoring = true
	teleport_area.visible = true

func check_submission(submitted_item_name: String) -> bool:
	if !game_active or current_idx >= current_queue.size():
		return false
	
	var current_target = current_queue[current_idx]
	
	if submitted_item_name == current_queue[current_idx]:
		# Correct object
		score += 1
		obj += 1
		current_idx += 1
		play_sfx(sound_correct)
		
		label_3d.modulate = Color.GREEN
		
		if current_idx >= current_queue.size():
			end_game_win()
		else:
			var tween = create_tween()
			tween.tween_property(label_3d, "modulate", Color.WHITE, 1.0)
			update_board_disp()
			
		return true
	else:
		# Incorrect object
		score -= 1
		wrong_picks += 1 # --- NEW ANALYTICS ---
		play_sfx(sound_incorrect)
		
		var mistake_text = "Target: %s | Player memilih: %s" % [current_target, submitted_item_name]
		error_log += mistake_text + "\n"
		
		update_board_disp()
		
		label_3d.modulate = Color.RED
		var tween = create_tween()
		tween.tween_property(label_3d, "modulate", Color.WHITE, 1.0)
		
		return false

func play_sfx(stream: AudioStream):
	if sound_player and stream:
		sound_player.stream = stream
		sound_player.play()

func format_seconds(amount: float) -> String:
	var clean_time = max(0.0, amount)
	var minutes = int(clean_time / 60)
	var seconds = int(clean_time) % 60
	
	return "%02d:%02d" % [minutes,seconds]

# --- NEW ANALYTICS: Permanent CSV/Excel Export Logic ---
func save_analytics_to_csv(time_taken: String, outcome: String):
	# user:// saves to the OS app data folder safely on PC, Quest, or Android
	var file_path = "/storage/emulated/0/Download/vr_session_analytics.csv"
	var file_exists = FileAccess.file_exists(file_path)
	
	# Open file in READ_WRITE to append without overwriting past sessions
	var file = FileAccess.open(file_path, FileAccess.READ_WRITE)
	if not file:
		# If file didn't exist at all, create it
		file = FileAccess.open(file_path, FileAccess.WRITE)
		
	if file:
		file.seek_end() # Move cursor to the very end of the file to append a new row
		
		# If the file is brand new, write the Excel Header row first
		if not file_exists or file.get_position() == 0:
			# Tambahkan "Subject ID" di paling depan
			file.store_line("Subject ID,Scene Label,Outcome,Time Taken,Score,Wrong Picks,Controller Distance (Meters),Raycast Hits")
			
		# Compile this round's telemetry into a comma-separated row
		# Tambahkan %s di paling depan untuk Subject ID
		var csv_row = "%s,%s,%s,%s,%d,%d,%.2f,%d" % [
			SessionData.subject_id,
			scene_name_override,
			outcome,
			time_taken,
			score,
			wrong_picks,
			controller_distance,
			raycast_hits
		]
		
		file.store_line(csv_row)
		file.close()
		
		file.store_line(csv_row)
		file.close()
		
		# Print the absolute OS file path so you know exactly where to find the spreadsheet
		print("\n>>> ANALYTICS SAVED TO EXCEL/CSV <<<")
		print("Path: ", ProjectSettings.globalize_path(file_path))
		print("Row Data: ", csv_row, "\n")

# If button pressed start new round
func _on_interactable_area_button_button_pressed(_button):
	start_new_round()
