extends Node3D
@onready var pickable_wood_block = $PickableWoodBlock
@onready var text = %Text

var show_text_bool: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	text.visible = show_text_bool
	pickable_wood_block.connect("picked_up", onPickedUp)


func onPickedUp(block):
	print("picked Up")
	show_text_bool = true
	text.visible = show_text_bool
