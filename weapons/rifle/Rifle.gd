extends Sprite

const Bullet = preload("res://weapons/bullet/Bullet.tscn")

func _process(_delta):
	if is_network_master():
		if Input.is_action_pressed('shoot') and $Timer.is_stopped():
			rpc('_shoot')
			$Timer.start()

func _on_Timer_timeout():
	$Timer.stop()

remotesync func _shoot():
	var bullet = Bullet.instance()
	add_child(bullet)
	bullet.global_position = global_position
	bullet.direction = -1 if flip_h else 1
