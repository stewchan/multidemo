extends RigidBody2D

export(float) var damage = 15.0



func _ready():
	$AnimatedSprite.playing = true
	var mob_types = $AnimatedSprite.frames.get_animation_names()
	$AnimatedSprite.animation = mob_types[randi() % mob_types.size()]
	$Tween.interpolate_property($AnimatedSprite, "modulate:a", 1, 0, 0.2)
	$DeathTween.interpolate_property($AnimatedSprite, "modulate:a", 1, 0, 0.2)
	$DeathTimer.start()


# Called when mob collides into player
func explode() -> float:
	$CollisionShape2D.disabled = true
	linear_velocity = Vector2.ZERO
	$AnimatedSprite.playing = false
	$Tween.start()
	return damage


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_Tween_tween_all_completed():
	queue_free()


func _on_DeathTimer_timeout():
	$DeathTween.start()


func _on_DeathTween_tween_all_completed():
	queue_free()
