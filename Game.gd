extends Node

export(PackedScene) var player_scene
export(PackedScene) var mob_scene

onready var mob_timer = $MobTimer


func _ready():
	get_tree().connect("network_peer_disconnected", self, "_on_player_disconnected")
	get_tree().connect("server_disconnected", self, "_on_server_disconnected")

	var new_player = player_scene.instance()
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


remotesync func _spawn_mob(rand_offset: float, rand_direction: float, rand_velocity: Vector2):
	var mob = mob_scene.instance()
	var mob_spawn_location = get_node("MobPath/MobSpawnLocation")
	# Set the mob's position to a random location from 0 to 1 on the path.
	mob_spawn_location.unit_offset = rand_offset
	mob.position = mob_spawn_location.position
	# Set the mob's direction perpendicular to the path direction and add some randomness.
	var direction = mob_spawn_location.rotation + PI / 2 + rand_direction
	mob.rotation = direction
	# Set the mob's velocity
	mob.linear_velocity = rand_velocity.rotated(direction)

	add_child(mob)


func _on_MobTimer_timeout():
	if get_tree().is_network_server():
		# Randomize mob direction and velocity
		var offset = randf()
		var direction = rand_range(-PI / 4, PI / 4)
		var velocity = Vector2(rand_range(150.0, 250.0), 0.0)
		rpc("_spawn_mob", offset, direction, velocity)
		mob_timer.start()
