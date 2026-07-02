extends Node2D

@export var monedas_requeridas: int = 1

@onready var coins_label: Label = $CoinsLabel
@onready var door: Area2D = $Door

func _ready() -> void:
	if coins_label:
		coins_label.text = "0/" + str(monedas_requeridas)

func registrar_moneda_recolectada(cantidad_actual: int) -> void:
	if coins_label:
		coins_label.text = str(cantidad_actual) + "/" + str(monedas_requeridas)
	
	if cantidad_actual >= monedas_requeridas:
		if door and door.has_method("open_door"):
			door.open_door()
			
