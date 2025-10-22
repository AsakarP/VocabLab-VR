extends Node3D

@onready var interactable_area_button = $InteractableAreaButton
@onready var text = %Text

var show_text_bool: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	text.visible = show_text_bool
	interactable_area_button.connect("button_pressed", onButtonPressed)
		
func onButtonPressed(button):
	print("Pressed!")
	show_text_bool = true
	text.visible = show_text_bool
