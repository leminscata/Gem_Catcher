extends Node2D

# Configura cuántas monedas se necesitan en ESTE nivel específico
@export var monedas_requeridas: int = 1

@onready var coins_label: Label = $CoinsLabel # O "coinlabel" según tu editor
@onready var door: Area2D = $Door

func _ready() -> void:
	# Inicializa el texto del marcador con el total dinámico del nivel
	if coins_label:
		coins_label.text = "0/" + str(monedas_requeridas)

# Esta función la llamará la moneda cada vez que el jugador agarre una
func registrar_moneda_recolectada(cantidad_actual: int) -> void:
	# 1. Actualiza el texto en pantalla usando el total del nivel
	if coins_label:
		coins_label.text = str(cantidad_actual) + "/" + str(monedas_requeridas)
	
	# 2. Compara si ya se alcanzaron las monedas necesarias en este mapa
	if cantidad_actual >= monedas_requeridas:
		if door and door.has_method("open_door"):
			door.open_door()
			
