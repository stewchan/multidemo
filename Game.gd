extends Node

export(PackedScene) var mob_scene

onready var mob_timer = $MobTimer


func _ready():
	get_tree().connect("network_peer_disconnected", self, "_on_player_disconnected")
	get_tree().connect("server_disconnected", self, "_on_server_disconnected")

	var new_player = preload("res://player/Player.tscn").instance()
	new_player.name = str(get_tree().get_network_unique_id())
	new_player.set_network_master(get_tree().get_network_unique_id())
	add_child(new_player)
	var info = Network.self_data
	new_player.init(info.name, info.position, false)

	# Server starts the game
	if get_tree().is_network_server():
		start_game()


func start_game():
	mob_timer.start()


func _on_player_disconnected(id):
	get_node(str(id)).queue_free()


func _on_server_disconnected():
	get_tree().change_scene("res://interface/Menu.tscn")


remotesync func _spawn_mob():
	var mob = mob_scene.instance()

	# Choose a random location on Path2D.
	var mob_spawn_location = get_node("MobPath/MobSpawnLocation")
	mob_spawn_location.offset = randi()

	# Set the mob's direction perpendicular to the path direction.
	var direction = mob_spawn_location.rotation + PI / 2

	# Set the mob's position to a random location.
	mob.position = mob_spawn_location.position

	# Add some randomness to the direction.
	direction += rand_range(-PI / 4, PI / 4)
	mob.rotation = direction

	# Choose the velocity for the mob.
	var velocity = Vector2(rand_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)


func _on_MobTimer_timeout():
	_spawn_mob()
	mob_timer.start()
