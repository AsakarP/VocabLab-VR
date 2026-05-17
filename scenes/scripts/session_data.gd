extends Node

var current_id_number: int = 1
var subject_id: String = "Subject01"
var is_first_load: bool = true

func next_subject():
	current_id_number += 1
	subject_id = "Subject%02d" % current_id_number
