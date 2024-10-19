extends Node

@export var ITEM_DB_Storage = {}  # Здесь будут храниться данные о всех вещах
@export var server_clothes_list = []  # Общий список одежды
@export var requirementD = {}  # Другие данные, связанные с вещами

var requirement:int = 1:
	set(value):
		requirement = value
	get():
		return requirement

# Функция для добавления одежды в общий список на сервере
func add_clothes_to_list(data: Dictionary) -> void:
	server_clothes_list.append(data)
	update_clothes_list_on_clients()  # Синхронизируем с клиентами

# Функция для перемешивания списка одежды
func shuffle_clothes_list() -> void:
	server_clothes_list.shuffle()
	update_clothes_list_on_clients()

# Отправляем обновленный список клиентам через RPC
@rpc("any_peer", "reliable")
func update_clothes_list_on_clients() -> void:
	rpc("receive_clothes_list", server_clothes_list)

# Клиенты получают обновленный список одежды
@rpc("any_peer", "reliable")
func receive_clothes_list(clothes_list: Array) -> void:
	server_clothes_list = clothes_list
	print("Обновленный список одежды на клиенте: ", server_clothes_list)

# Пример использования: добавление одежды на сервере
func add_new_clothes() -> void:
	var rnd = RandomNumberGenerator.new()
	var new_clothes = {
		"ImagePath": "res://Game/IMG/untitled-removebg-preview.png",
		"Type": Global.ClotheTypes[rnd.randi_range(0, Global.ClotheTypes.size() - 1)],
		"ID": str(rnd.randi_range(1000, 9999)) + "/" + str(rnd.randi_range(0, 9999)),
		"ColorID": rnd.randi_range(0, 10)
	}
	add_clothes_to_list(new_clothes)

# Функция для перемешивания списка при достижении требования
func update_25_list(R:int) -> void:
	if multiplayer.is_server():  # Только сервер должен обновлять список
		return

	# Добавляем новые вещи, если нужно
	if (R > requirementD.size()):
		for i in range(R - requirementD.size()):
			add_new_clothes()

	# После добавления можем перемешать список
	shuffle_clothes_list()
