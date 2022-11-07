extends KinematicBody2D

const MOVE_SPEED = 10.0
const MAX_HP = 100

var health_points := MAX_HP
var is_alive := true
var velocity := Vector2.ZERO
var touch_target
var screen_size
var weapon


func _ready():
	screen_size = get_viewport_rect().size
	set_position(screen_size / 2)
	_update_health_bar()


func _physics_process(_delta):
	# Do nothing if player is dead
	is_alive = health_points > 0
	if not is_alive:
		return

	# Stop moving when the touch target is reached
	if touch_target != null and position.distance_to(touch_target) < 5:
		touch_target = null
		velocity = Vector2.ZERO

	rpc("move", velocity)

	# Update server with new player positions
	# if get_tree().is_network_server():
	# 	Network.update_position(int(name), position)


remotesync func move(vel):
	var collision = move_and_collide(vel * MOVE_SPEED, false)
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)
	if collision and collision.collider.has_method("explode"):
		rpc("damage", collision.collider.explode())


func _update_health_bar():
	$GUI/HealthBar.value = health_points


remotesync func damage(value):
	health_points -= value
	if health_points <= 0:
		health_points = 0
		rpc("_die")
	_update_health_bar()


remotesync func _die():
	$RespawnTimer.start()
	set_physics_process(false)
	$Rifle.set_process(false)
	for child in get_children():
		if child.has_method("hide"):
			child.hide()
	$CollisionShape2D.disabled = true


func _on_RespawnTimer_timeout():
	set_physics_process(true)
	$Rifle.set_process(true)
	for child in get_children():
		if child.has_method("show"):
			child.show()
	$CollisionShape2D.disabled = false
	health_points = MAX_HP
	_update_health_bar()


func init(nickname, start_position, is_puppet):
	$GUI/Nickname.text = nickname
	global_position = start_position
	if is_puppet:
		$Sprite.texture = load("res://player/player-alt.png")


func _input(event):
	if not (is_network_master() and is_alive):
		return

	var shooting = false
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		touch_target = event.position
		velocity = (touch_target - position).normalized()
		shooting = true
	elif event is InputEventKey:
		if event.is_pressed():
			if Input.is_action_pressed("ui_right"):
				velocity.x += 1
			if Input.is_action_pressed("ui_left"):
				velocity.x -= 1
			if Input.is_action_pressed("ui_up"):
				velocity.y -= 1
			if Input.is_action_pressed("ui_down"):
				velocity.y += 1
			if Input.is_action_pressed("shoot"):
				shooting = true
			velocity = velocity.normalized()
		else:
			velocity = Vector2.ZERO

	# Fix rifle orientation
	if weapon != null:
		if velocity != Vector2.ZERO:
			var facing_left = velocity.x < 0
			$Rifle.orient(facing_left)

		if shooting:
			$Rifle.shoot()
