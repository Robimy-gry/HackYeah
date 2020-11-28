extends KinematicBody2D

onready var BULLET_SCENE = preload("res://Bullet.tscn")

var player = null
var move = Vector2.ZERO
var speed = 10

func _physics_process(delta):
	move = Vector2.ZERO
	
	if player != null:
		move = position.direction_to(player.position) * speed
	else:
		move = Vector2.ZERO
	
	move = move.normalized()
	move = move_and_collide(move)
	
func fire():
	var bullet = BULLET_SCENE.instance()
	bullet.position = get_global_position()
	bullet.player = player
	get_parent().add_child(bullet)
	$Timer.set_wait_time(3)

func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		player = body

func _on_Area2D_body_exited(body):
	player = null
	
func _on_Timer_timeout():
	if player != null:
		fire()
