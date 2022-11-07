extends Control

onready var text = $TextField

var _player_name = ""


func _ready():
	# warning-ignore:return_value_discarded
	text.grab_focus()


func _on_TextField_text_changed(new_text):
	_player_name = new_text


# Host a game
func _on_CreateButton_pressed():
	if _player_name == "":
		return
	Gotm.host_lobby(false)
	Gotm.lobby.name = "Multiplayer creeps demo"
	Gotm.lobby.hidden = false
	Network.create_server(_player_name)
	_load_game()


# Join a game
func _on_JoinButton_pressed():
	if _player_name == "":
		return

	var fetch = GotmLobbyFetch.new()
	var lobbies = yield(fetch.first(), "completed")
	if lobbies.size() == 0:
		print("No lobbies found")
		return

	var success = yield(lobbies[0].join(), "completed")

	Network.connect_to_server(_player_name, Gotm.lobby.host.address)

	_load_game()


func _load_game():
	get_tree().change_scene("res://Game.tscn")
