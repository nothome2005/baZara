extends Control

@export var Data = {
	"ImagePath":"",
	"Type":"",
	"ID":"",
	"Position":0,
	"Num":1	
}
var page:int = 0
var active:bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ColorRect/MarginContainer/VBoxContainer/Info/MarginContainer/HBoxContainer/TypeName.text = Data["Type"]
	$ColorRect/MarginContainer/VBoxContainer/Info/MarginContainer2/HBoxContainer2/IDNum.text = Data["ID"]
	$ColorRect/MarginContainer/VBoxContainer/Info/MarginContainer3/HBoxContainer2/Position.text = str(Data["Position"])
	$ColorRect/MarginContainer/VBoxContainer/CenterContainer/Count.text = str(Data["Num"])

func SetData(d) -> void:
	$ColorRect/MarginContainer/VBoxContainer/Info/MarginContainer/HBoxContainer/TypeName.text = d["Type"]
	$ColorRect/MarginContainer/VBoxContainer/Info/MarginContainer2/HBoxContainer2/IDNum.text = d["ID"]
	$ColorRect/MarginContainer/VBoxContainer/Info/MarginContainer3/HBoxContainer2/Position.text = str(d["Position"])
	$ColorRect/MarginContainer/VBoxContainer/CenterContainer/Count.text = str(d["Num"])
	$ColorRect/MarginContainer/VBoxContainer/Photo/PhotoRect.texture = load(d["ImagePath"])
	$ColorRect/MarginContainer/VBoxContainer/Photo/PhotoRect.self_modulate = Color(Global.colorRGB[d["ColorID"]][0],Global.colorRGB[d["ColorID"]][1],Global.colorRGB[d["ColorID"]][2])
	PageView()
	
func PageView() -> void:
	$ColorRect/MarginContainer/VBoxContainer/CenterContainer/Count.text = "%d/%d" %[page+1,sv25.requirementD.size()]


func _unhandled_input(_event: InputEvent) -> void:
	if !active:
		return
	if Input.is_action_just_pressed("next"):
		if page < (sv25.requirementD.size()-1):
			page += 1
			refresh()
	elif Input.is_action_just_pressed("previous"):
		if page > 0:
			page -= 1
			refresh()
			

func refresh() -> void:
	# Проверяем, что словарь requirementD не пустой и индекс page допустимый
	if sv25.requirementD.size() > 0 and page >= 0 and page < sv25.requirementD.keys().size():
		SetData(sv25.requirementD[sv25.requirementD.keys()[page]])
	else:
		print("Ошибка: Пустой словарь или недопустимый индекс 'page': ", page)
