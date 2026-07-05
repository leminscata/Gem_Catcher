extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $Sprites
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
@onready var death_sound: AudioStreamPlayer2D = $DeathSound
@onready var reset_sound: AudioStreamPlayer2D = $ResetSound
@onready var CoyoteTimer: Timer = $CoyoteTime
@onready var coins_label: Label = $"../CoinsLabel"

var was_on_floor: bool = false
var is_dead: bool = false 

const SPEED = 150.0
const ACCEL = 300
const FRICTION = 500.0
const JUMP_VELOCITY = -325.0
const ENEMY_BOUNCE_VELOCITY = -400.0 

var coin_counter = 0

func _physics_process(delta: float) -> void: #srocesa las fisicas cada segundo
	
	if Input.is_action_just_pressed("restart"):
		if is_inside_tree():
			reset_sound.play()
			await get_tree().create_timer(0.2).timeout
			
			# Forces Godot to clear cached resources so they reset entirely
			var current_scene_path = get_tree().current_scene.scene_file_path
			ResourceLoader.has_cached(current_scene_path) 
			
			get_tree().reload_current_scene()
			return


	if is_dead:
		velocity.y += 980.0 * delta #hace que caiga al morir
		
		if is_on_floor() and velocity.y >= 0: #si esta en el piso y su velocidad vertical es 0
			velocity = Vector2.ZERO #detiene toda velocidad
		
		move_and_slide() #sirve para frenar al personaje cuando detecte el piso
		
		if animated_sprite_2d.animation != "Dead":
			animated_sprite_2d.play("Dead")
		return #esto hace que si la animacion de muerte no esta ocurriendo, pues que ocurra y el return es para que oucrra solo una vez 
	
	if not is_on_floor():
		velocity += get_gravity() * delta #aplica la gravedad del motor
	
	if was_on_floor and not is_on_floor() and velocity.y >= 0: #si estaba en el piso, y no esta en el piso y su velocidad vertical es mayor que 0
		CoyoteTimer.start() #hace que empieze el nodo de temporizador
	
	was_on_floor = is_on_floor() 
	
	if Input.is_action_just_pressed("jump") and (is_on_floor() or not CoyoteTimer.is_stopped()):
		velocity.y = JUMP_VELOCITY
		jump_sound.play()
		CoyoteTimer.stop()
		
	var direction := Input.get_axis("left", "right")

	if direction != 0:
		# Al caminar, aplicamos la aceleración normal
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCEL * delta)
	else:
		# Al soltar el control, aplicamos la fricción (que es mucho más alta)
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

	move_and_slide()

	for i in get_slide_collision_count(): #Devuelve el número de objetos con los que el personaje está chocando en este fotograma exacto tras haber ejecutado move_and_slide().
		var collision = get_slide_collision(i) #Obtiene los datos detallados (ángulos, puntos de impacto) de la colisión número i.
		var collider = collision.get_collider() #Identifica el objeto físico real (el nodo) contra el que chocaste.
		
		if collider and "is_dead" in collider and not collider.is_dead: 
			#collider comprueba que el objeto exista y no sea nulo
			#"is_dead" in collider: Verifica si el enemigo tiene una variable llamada is_dead en su script. Esto asegura que no intentes matar a una pared o a una moneda.
			#not collider.is_dead: Comprueba que el enemigo esté vivo. Si ya está muerto, lo ignora para no volver a aplastarlo.
			
			if collision.get_normal().y < -0.5: #si collision vertical es -0.5, es decir hacia arriab
				collider.die() #llama a la funcion die() que hace que el enemigo muera
				velocity.y = ENEMY_BOUNCE_VELOCITY #aplica la variable de rebote a la velocidad vertical del jugador
			else:
				die() #si el choque no vino desde el eje y -0.5 entonces es un choche lateral, por lo que die() se aplica al jugador


	if direction == 1.0: #si la direccion es derecha "1.0"
		animated_sprite_2d.flip_h = false #no des vuelta horizontalmente a la animacion del personaje
	elif direction == -1.0: #si la dirrecion es izquirda "-1.0"
		animated_sprite_2d.flip_h = true #da vuelta horizontalmente a la animacion del personaje


	if not is_on_floor(): #si no esta ene el piso
		if animated_sprite_2d.animation != "Jump": #y si la animacion de salto no esta reproduciendose
			animated_sprite_2d.play("Jump") #repoducela
	else: 
		if velocity.x > 1 or velocity.x < -1: #si la velocidad horizontal es mayor que 1 o menor que -1 
			animated_sprite_2d.play("Run") #reproduce la animacion de correr
		else: 
			animated_sprite_2d.play("Idle") #si no reproduce la animacion de estar quieto


func _on_coin_hit_box_area_entered(area: Area2D) -> void: #la funcion se ejecuta cuando area entered de coin
	if area.owner and area.owner.is_in_group("coin"): #comprueba si el area es del grupo coin
		set_coin(coin_counter + 1) #si es asi suma 1
		area.owner.queue_free() #hace que el nodo desaparezca

func set_coin(new_coin_count: int) -> void: #nre_coint_coint: int es la fucnion pidiendote un dato, como es int, es un numero
	coin_counter = new_coin_count #toma el valor dado por la funcion anterior y lo agrega a new_coin_counter
	
	if coins_label:
		coins_label.text = str(coin_counter) + "/2" #coins_label.text accede al texto del CoinsLabel, str() transforma en text y el + "/2" hace concat por lo que "1" + "/2" daria 1/2 al ser texto
	else:
		print("Error: No se encontró CoinsLabel. Verifica la ruta en la variable @onready.")

func die() -> void:
	if is_dead:
		return #las dos primeras lineas evita que puedas morir 2 veces
		
	is_dead = true #hace que la variable sea true
	
	if has_node("CollisionShape2D"): #verifica si el objeto tiene un nodo de colision
		$CollisionShape2D.set_deferred("disabled", true) #apaga la colision del personaje
	
	if death_sound:
		death_sound.play()
	
	animated_sprite_2d.play("Dead")
	

	velocity.y = -250.0 #hace que el jugador pegue un salto al morir
	velocity.x = 0 
	

	await get_tree().create_timer(1.5).timeout #aplica un temporizador para el codigo de abajo
	get_tree().reload_current_scene() #recarga la escena
