extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	$StaticBody3D4.visible = true
	await get_tree().create_timer(6).timeout
	sv25.update_25_list(2)
	print(scene_file_path)
