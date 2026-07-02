extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var open_sound: AudioStreamPlayer2D = $OpenSound
@onready var win_sound_node: AudioStreamPlayer2D = $WinSound 

@export_file("*.tscn") var next_scene_path: String

var is_open: bool = false

func _ready() -> void:
	animated_sprite_2d.play("Closed")

func open_door() -> void:
	if not is_open:
		is_open = true 
		
		await get_tree().create_timer(0.3).timeout
		
		if open_sound: 
			open_sound.play()
			
		if animated_sprite_2d.sprite_frames.has_animation("Opening"):
			animated_sprite_2d.play("Opening")
			await animated_sprite_2d.animation_finished
			
		if animated_sprite_2d.sprite_frames.has_animation("Open"):
			animated_sprite_2d.play("Open")

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		if is_open:
			set_deferred("monitoring", false)
			
			if body.has_method("set_physics_process"):
				body.set_physics_process(false) 
			body.hide() 
			
			if win_sound_node:
				win_sound_node.play()
				await win_sound_node.finished
			else:
				await get_tree().create_timer(0.5).timeout
			
			if next_scene_path != "":
				get_tree().change_scene_to_file(next_scene_path)
			else:
				print("¡Error: Olvidaste asignar la siguiente escena en el Inspector de esta puerta!")
