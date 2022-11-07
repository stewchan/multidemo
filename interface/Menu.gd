extends Control

onready var text = $TextField

var _player_name = ""


func _ready():
	# Set up lobby system
	# warning-ignore:return_value_discarded

	text.grab_focus()


func _on_TextField_text_changed(new_text):
	_player_name = new_text


# Host a game
func _on_CreateButton_pressed():
	if _player_name == "":
		return
	Network.create_server(_player_name)
	_load_game()


# Join a game
func _on_JoinButton_pressed():
	if _player_name == "":
		return
	Network.connect_to_server(_player_name)
	_load_game()


func _load_game():
	get_tree().change_scene("res://Game.tscn")
