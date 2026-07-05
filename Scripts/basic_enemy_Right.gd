extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var hitbox_collision: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var death_sound: AudioStreamPlayer2D = $DeathSound

const SPEED = 35.0
var direction = 1.0 
var is_dead = false 
var _inicio_bloqueado = true

func _ready() -> void:
	direction = 1.0
	_update_raycast_and_sprite()
	await get_tree().create_timer(0.05).timeout
	_inicio_bloqueado = false

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	velocity.x = direction * SPEED
	
	move_and_slide()
	animated_sprite_2d.play("Moving")

	if _inicio_bloqueado:
		return

	if is_on_wall():
		var golpeo_al_jugador = false
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider and collider.name.to_lower().contains("player"):
				if "is_dead" in collider and not collider.is_dead:
					golpeo_al_jugador = true
					collider.die() 
					break
		if not golpeo_al_jugador:
			direction *= -1.0 
			_update_raycast_and_sprite()
			
	elif not ray_cast_2d.is_colliding():
		direction *= -1.0 
		_update_raycast_and_sprite()

func _update_raycast_and_sprite() -> void:
	if direction == 1.0:
		animated_sprite_2d.flip_h = false
		ray_cast_2d.position.x = abs(ray_cast_2d.position.x)
	else:
		animated_sprite_2d.flip_h = true
		ray_cast_2d.position.x = -abs(ray_cast_2d.position.x)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if is_dead:
		return
	if body is CharacterBody2D and body != self:
		if "velocity" in body and body.velocity.y > 0:
			die()
			if "ENEMY_BOUNCE_VELOCITY" in body:
				body.velocity.y = body.ENEMY_BOUNCE_VELOCITY
			else:
				body.velocity.y = -450.0 

func die() -> void:
	is_dead = true
	velocity = Vector2.ZERO 
	if death_sound:
		death_sound.play()
	if is_instance_valid(collision_shape_2d): collision_shape_2d.queue_free()
	if is_instance_valid(hitbox_collision): hitbox_collision.queue_free()
	animated_sprite_2d.play("Dead")
	await animated_sprite_2d.animation_finished
	queue_free()
