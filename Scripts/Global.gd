extends Node

#Global Data
var ItemsCount:int = 0
var is_server:bool = false

#Clothes
const IMGname = []
const color = [800,400,500,600,700,300,900,100,200,550,650]
const colorRGB = [[0,0,0],[255,255,255],[255,0,0],[0,0,255],[0,255,0],[255,255,0],[128,0,128],[128,128,128],[255,192,203],[255,165,0],[64,224,208]]
const ClotheTypes = ["Blazers", "Trousers", "Dresses", "Skirts", "Jeans", "Coats", "T-shirts", "Sweaters", "Jackets", "Jumpsuits", "Cardigans", "Shorts"]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
