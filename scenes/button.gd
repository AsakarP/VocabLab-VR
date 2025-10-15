extends StaticBody3D

@onready var anim = $AnimationPlayer

func _on_area_3d_body_entered(body):
	anim.play("pressdown")
	print("pressed")

func _on_area_3d_body_exited(body):
	anim.play("release")
	print("released")
