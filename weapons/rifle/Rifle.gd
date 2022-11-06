extends Sprite

const Bullet = preload("res://weapons/bullet/Bullet.tscn")

# func _process(_delta):
# 	if is_network_master():
# 		if Input.is_action_pressed("shoot") and $Timer.is_stopped():
# 			rpc("shoot")
# 			$Timer.start()


func _on_Timer_timeout():
	$Timer.stop()


remotesync func _shoot():
	var bullet = Bullet.instance()
	add_child(bullet)
	bullet.global_position = global_position
	bullet.direction = -1 if flip_h else 1


remotesync func _orient(is_left_facing: bool):
	position.x = -abs(position.x) if is_left_facing else abs(position.x)
	flip_h = is_left_facing


func orient(is_left_facing: bool):
	rpc("_orient", is_left_facing)


func shoot():
	if not is_network_master():
		return
	if not $Timer.is_stopped():
		return

	$Timer.start()
	rpc("_shoot")
