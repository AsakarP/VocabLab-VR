extends Node

var current_id_number: int = 1
var subject_id: String = "Subject01"
var is_first_load: bool = true # Mencegah ID naik saat game baru pertama kali dibuka

# Fungsi ini akan dipanggil setiap kali player masuk ke Lobby
func next_subject():
	# Jika partisipan sebelumnya sudah selesai dan kembali ke lobby, tambahkan +1
	current_id_number += 1
	
	# %02d akan otomatis membuat format angka menjadi dua digit (01, 02, 03... 10, 11)
	subject_id = "Subject%02d" % current_id_number
	print(">>> PARTISIPAN BARU: ", subject_id, " <<<")
