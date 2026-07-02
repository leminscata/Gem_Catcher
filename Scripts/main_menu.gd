extends Control

@onready var start_button = $Start
@onready var exit_button = $Exit

@onready var sonido_navegar = $NavSound
@onready var sonido_aceptar = $AcceptSound

var menu_cargado = false

func _ready() -> void:
	start_button.focus_entered.connect(_on_boton_enfocado)
	exit_button.focus_entered.connect(_on_boton_enfocado)
	
	start_button.mouse_entered.connect(_on_boton_enfocado)
	exit_button.mouse_entered.connect(_on_boton_enfocado)
	
	start_button.grab_focus()
	
	menu_cargado = true

func _process(delta: float) -> void:
	pass

func _on_boton_enfocado() -> void:
	if menu_cargado and sonido_navegar:
		sonido_navegar.play()

func _on_start_pressed() -> void:
	if sonido_aceptar:
		sonido_aceptar.play()
	
	start_button.disabled = true
	exit_button.disabled = true
	
	await get_tree().create_timer(0.3).timeout 
	get_tree().change_scene_to_file("res://Scenes/Levels/Tutorial.tscn") #salto entre nivel
	

func _on_exit_pressed() -> void:
	if sonido_aceptar:
		sonido_aceptar.play()
		
	start_button.disabled = true
	exit_button.disabled = true
	
	await get_tree().create_timer(0.3).timeout
	get_tree().quit()
