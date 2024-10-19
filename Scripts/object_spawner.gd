extends Node3D

@export var Num: int
@export_range(0, 100) var Chance: int = 50
@export_file("Node3D") var ClothesNode

var scene = preload("res://Game/Scenes/clothes.tscn")
var rnd: RandomNumberGenerator
var event: int
const shelf = [1, 4, 7, 2, 5, 8, 3, 6, 9]
var is_server: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MeshInstance3D/Label3D.text = str(Num)
	rnd = RandomNumberGenerator.new()
	is_server = multiplayer.is_server()
	print(is_server)
	await get_tree().create_timer(5).timeout
	for i in range(9):
		event = randi_range(0, 100)
		if event < Chance:
			spawn_clothes(get_node("Node3D%d/%d" % [(roundi(i / 3) + 1), shelf[i]]))
	if is_server:
		rpc("broadcast_clothes_list", server_clothes_list)

func spawn_clothes(pos: Node3D) -> void:
	var clothes_instance = scene.instantiate()
	clothes_instance.Data["Position"] = Num
	add_child(clothes_instance, true)
	clothes_instance.global_transform.origin = pos.global_position
	if is_server:
		rpc("spawn_object_on_clients", clothes_instance.get_path(), clothes_instance.Data["Position"])

@rpc("any_peer", "reliable")
func spawn_object_on_clients(object_path: NodePath, n: int) -> void:
	if has_node(object_path):
		var clothes_instance = get_node(object_path) as Node3D
		clothes_instance.Data["Position"] = n
	else:
		var clothes_instance = scene.instantiate()
		clothes_instance.Data["Position"] = n
		add_child(clothes_instance)

@rpc("any_peer", "reliable")
func broadcast_clothes_list(clothes_list: Array) -> void:
	for item in clothes_list:
		rpc("sync_clothes_data", item)

@rpc("any_peer", "reliable")
func sync_clothes_data(data: Dictionary) -> void:
	var clothes_instance = scene.instantiate()
	clothes_instance.Data = data
	$MeshInstance3D/Label3D.text = clothes_instance.Data["ID"]
	var material = StandardMaterial3D.new()
	$MeshInstance3D.set_surface_override_material(0, material)
	material.albedo_color = Color(Global.color[clothes_instance.Data["ColorID"]])
	add_child(clothes_instance)
