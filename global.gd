extends Node



# Called when the node enters the scene tree for the first time.
func _ready():
	Gotm.initialize()
	var config = GotmConfig.new()
	# Replace the empty string with your project key.
	config.project_key = "authenticators/O5zjcGWv3B7tycFWqZvE"
	Gotm.initialize(config)
