extends Area2D

export(float) var SPEED = 1500.0
export(float) var DAMAGE = 15.0

var direction = 0

func _ready():
	set_as_toplevel(true)

func _process(delta):
	position.x += direction * SPEED * delta

func _on_body_entered(body):
	# Ignore if body is the rifle
	if body.is_a_parent_of(self):
		return
	# Ignore if body is not a player
	if not body.is_in_group('players'):
		return
	# Apply damage
	body.damage(DAMAGE)
	queue_free()

# Remove bullet if it goes off screen
func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
