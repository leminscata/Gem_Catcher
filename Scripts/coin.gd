extends Area2D

@onready var coin_sound: AudioStreamPlayer2D = $CoinSound

func _on_area_entered(area: Area2D) -> void:
	var player = area.owner
	
	if player and "coin_counter" in player:
		player.coin_counter += 1
		
		var current_node = get_parent()
		while current_node != null:
			if current_node.has_method("registrar_moneda_recolectada"):
				current_node.registrar_moneda_recolectada(player.coin_counter)
				break
			current_node = current_node.get_parent() 
	
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	
	if coin_sound: 
		coin_sound.play()
		
	hide()
	
	if coin_sound: 
		await coin_sound.finished
		
	queue_free()
