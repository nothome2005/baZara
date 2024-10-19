extends Node3D

@export var Data = {
	"ImagePath": "res://Game/IMG/untitled-removebg-preview.png",
	"Type": "",
	"ID": "",
	"Position": 0,
	"Color": 1,
	"Num": 1
}

var server_clothes_list = []  # Общий список одежды, который будет синхронизирован

func _ready() -> void:
	add_to_group("Clothes")
	if multiplayer.is_server():  # Сервер создает одежду
		generate_clothes_data()
		add_to_clothes_list()

func generate_clothes_data() -> void:
	Global.ItemsCount += 1
	var rnd = RandomNumberGenerator.new()
	var color_id_temp = randi_range(0, 10)
	Data["ImagePath"] = "res://Game/IMG/untitled-removebg-preview.png"
	Data["Num"] = Global.ItemsCount
	Data["ColorID"] = color_id_temp
	Data["ID"] = str(randi_range(1000, 9999)) + "/" + str(randi_range(0, 9999)) + "/" + str(Global.color[color_id_temp])
	Data["Type"] = Global.ClotheTypes[rnd.randi_range(0, Global.ClotheTypes.size() - 1)]
	if multiplayer.is_server():
		rpc("sync_clothes_data", Data)  # Синхронизируем данные с клиентами

func add_to_clothes_list() -> void:
	var item_data = Data.duplicate()
	server_clothes_list.append(item_data)
	if multiplayer.is_server():
		rpc("update_clothes_list_on_clients", server_clothes_list)

@rpc("any_peer", "reliable")
func update_clothes_list_on_clients(clothes_list: Array) -> void:
	server_clothes_list = clothes_list
	sync_clothes_list()

func sync_clothes_list() -> void:
	for item in server_clothes_list:
		print("Одежда: ", item)

@rpc("any_peer", "reliable")
func sync_clothes_data(data: Dictionary) -> void:
	Data = data
	$Label3D.text = Data["ID"]
	var material = StandardMaterial3D.new()
	$MeshInstance3D.set_surface_override_material(0, material)
	material.albedo_color = Color(Global.color[Data["ColorID"]])

@rpc("any_peer", "reliable")
func update_clothes_data_on_clients(data: Dictionary) -> void:
	Data = data
	sync_clothes_data(Data)

@rpc("any_peer", "reliable")
func shuffle_clothes_list() -> void:
	if multiplayer.is_server():  # Только сервер может перемешивать
		server_clothes_list.shuffle()
		rpc("update_clothes_list_on_clients", server_clothes_list)

func _physics_process(_delta: float) -> void:
	if multiplayer.is_server():
		for obj in get_tree().get_nodes_in_group("Clothes"):
			if obj is RigidBody3D:
				rpc("sync_object_position", obj.name, obj.global_transform.origin)

@rpc("any_peer", "reliable")
func sync_object_position(object_name: String, position: Vector3) -> void:
	if has_node(object_name):
		var obj = get_node(object_name) as RigidBody3D
		obj.global_transform.origin = position
