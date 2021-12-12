extends KinematicBody2D

#Estados en los que se puede encontrar el zombie
var idle = false
var patrol = true
var run = false
var attack = false

#Variable que es verdadera si el zombie esta moviendose mientras patrulla.
var Patrolling = false
var DirectionPatrolling

var Player_Entered = false;

var Life = 100

export var Move_Speed = 250
var velocity = Vector2()

var player = null
var player_position;

var nav = Navigation2D


#var path = []

var PositionInitPatrol = Vector2() #posicion inicial donde empieza a patrullar el zombie.


var path: Array = []
var levelNavigation: Navigation2D = null

onready var line2d = $Line2D

func _ready():
	#yield(get_tree(), "idle_frame")
	var tree = get_tree()
	if tree.has_group("LevelNavigation"):
		levelNavigation = tree.get_nodes_in_group("Navigation")[0]
		pass
	$AnimacionZombie.play("Zombie_Idle")
	player = null
	$Timer_Cambio_Patrulla.start()
pass 


func _process(delta):
	pass
	

func _physics_process(delta):
	line2d.global_position = Vector2.ZERO
	if player and levelNavigation:
		generate_path()
		navigate()
	velocity = move_and_slide(velocity * Move_Speed)
	pass

func navigate():
	if path.size() > 0:
		velocity = global_position.direction_to(path[1]) * Move_Speed

		if global_position == path[0]:
			path.pop_front()
pass

func generate_path():
	if levelNavigation != null && player != null:
		path = levelNavigation.get_simple_path(global_position, player.global_position, false)
		line2d.points = path
	pass

	#Funciones para reducir la vida y eliminar al zombie.
func Reduce_Life(var Damage):
	if(Life > 0):
		Life -= Damage
		print(Life)
		if(Life <= 0):
			Kill_Zombie()
	else:
		Kill_Zombie()

func Kill_Zombie():
	queue_free()


	#Zonas de escucha del zombie
func _on_ZonaDeEscucha_body_entered(body):
	if body.is_in_group("Player"):
		print("Entro el jugador")
		Player_Entered = true;
		player = body;
	pass # Replace with function body.


func _on_ZonaDeEscucha_body_exited(body):
	if body.is_in_group("Player"):
		Player_Entered = false;
	pass # Replace with function body.
	

	#Funciones de control de tiempo.
func _on_Timer_Cambio_Patrulla_timeout():
	pass
	

func _on_Timer_Cambio_IdlePatrulla_timeout():
	if idle:
		patrol = true
		$Timer_Cambio_IdlePatrol.start()
	else:
		$Timer_Cambio_IdlePatrol.stop()
	pass
		
func Hear_Player():
	if(Player_Entered && player.run):

		#El zombie buscara el camino para atacar al jugador.
		pass

func State_Patrol():
	if(patrol):	#Estado patrol
		if($Timer_Cambio_IdlePatrol.is_stopped()):	#Si el timer de cambio de estado esta en stop
			$Timer_Cambio_IdlePatrol.play()	#lo inicio.
		if $Timer_Cambio_IdlePatrol.time_left > 5:
			if(!Patrolling):	#Si se encuentra moviendose mientras patrulla
				Patrolling = true
				PositionInitPatrol = position
				var RandomNum = RandomNumberGenerator.new()
				DirectionPatrolling = RandomNum.randf_range(0,3)
				match DirectionPatrolling:
					0:
						velocity.x = 1
						velocity.y = 0
					1: 
						velocity.x = -1
						velocity.y = 0
					2:
						velocity.x = 0
						velocity.y = 1
					3:
						velocity.x = 0
						velocity.y = -1
						
		else:
			idle = true
			Patrolling = false	
			
				
