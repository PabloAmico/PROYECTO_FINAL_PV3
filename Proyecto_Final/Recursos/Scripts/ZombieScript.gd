extends KinematicBody2D


export(int) var SPEED: int = 40
export(int) var SPEED_PATROL: int = 40



export(int) var Life : int = 100
var velocity: Vector2 = Vector2.ZERO

#pathFinding
var path: Array = []
var levelNavigation: Navigation2D = null
var player = null
var player_hear = null;

var player_enter = false;
var player_enter_hear = false;

#patrol

var assign_patrol = false;
var in_patrol = 0;
var assign_Dir = false;

#punch received
export(bool) var punch_received: bool = false
var punch_time = 0.3
var player_punch = null

#stab received
export(bool) var stun_received: bool = false
var stun_time = 0.75

func _ready():
	yield(get_tree(), "idle_frame")
	var tree = get_tree()
	player_punch = get_tree().get_nodes_in_group("Player")[0]
	randomize()
	
	if tree.has_group("LevelNavigation"):
		levelNavigation = tree.get_nodes_in_group("LevelNavigation")[0]
	
	if tree.has_group("Player"):
		player = tree.get_nodes_in_group("Player")[0]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	Hear_Player()
	


func _physics_process(delta):
	if player_enter:
		look_at(player.global_position)

	if player and levelNavigation:
		if player_enter && !punch_received && !stun_received:
			generate_path()
			navigate()
		elif punch_received:
			player_enter = true
			Punch_Received(delta)
		elif stun_received:
			player_enter = true
			Stun_Received(delta)
	
	idle_Patrol()
	move()


func idle_Patrol():
	if !player_enter:
		if $Timer_Cambio_IdlePatrol.time_left <= 0:
			assign_patrol = false
			assign_Dir = false
			$Timer_Cambio_IdlePatrol.start()
			
		pass
		if $Timer_Cambio_IdlePatrol.time_left > 0 && !assign_patrol:
			randomize()
			assign_Dir = true
			in_patrol = (randi() % 6) -1
			assign_patrol = true
		pass
		
		if assign_patrol && assign_Dir:
			match in_patrol:
				0: 
					velocity = Vector2(0,0) * SPEED_PATROL #patrulla quieto
					
					
				1: 
					velocity = Vector2(1,0) * SPEED_PATROL #patrulla a la derecha
					
					rotation_degrees = 0
				2: 
					velocity = Vector2(-1,0) * SPEED_PATROL #patrulla a la izquierda
					rotation_degrees = 180
					
					
				3: 
					velocity = Vector2(0,-1) * SPEED_PATROL #patrulla a la arriba
					rotation_degrees = -90
					
				4: 
					velocity = Vector2(0,1) * SPEED_PATROL #patrulla a la abajo
					rotation_degrees = 90
					
	else:
		$Timer_Cambio_IdlePatrol.stop()
		assign_patrol = false
		assign_Dir = false
		in_patrol = -1


func navigate():
	if player_enter:
		if path.size() > 0:
			velocity = global_position.direction_to(path[1]) * SPEED

			if global_position == path[0]:
				path.pop_front()
	


func generate_path():

	if levelNavigation != null and player != null:
		path = levelNavigation.get_simple_path(global_position, player.global_position, false)
	
func move():
	
		velocity = move_and_slide(velocity)

func Hear_Player():
	if player_hear:
		if player_hear.run && player_enter_hear:
			player_enter = true
	pass


func Reduce_Life(var Damage):
	if(Life > 0):
		Life -= Damage
		player_enter = true
		print("el daño sufrido fue = " + String(Damage))
		print(Life)
		if(Life <= 0):
			Kill_Zombie()
	else:
		Kill_Zombie()
	
func Kill_Zombie():
	queue_free()

func _on_ZonaDeEscucha_body_exited(body:Node):
	if body.is_in_group("Player"):
		player_hear = null
		player_enter_hear = false
	pass # Replace with function body.

func _on_ZonaDeEscucha_body_entered(body:Node):
	if body.is_in_group("Player"):
		player_hear = body
		player_enter_hear = true
	pass # Replace with function body.



func _on_ZonaDeVision_body_exited(body:Node):
	if body.is_in_group("Player"):
		player_enter = false
	pass # Replace with function body.

func _on_ZonaDeVision_body_entered(body:Node):
	if body.is_in_group("Player"):
		player_enter = true
	pass # Replace with function body.


func _on_hit_attack_body_entered(body):
	pass # Replace with function body.


func Punch_Received(var dt):
	if(punch_received):
		velocity = Vector2((position.x * cos(player_punch.rotation_degrees)*2), (position.y * sin(player_punch.rotation_degrees)*2))
		punch_time -= dt
		if(punch_time <= 0):
			punch_time = 0.3
			punch_received = false

func Stun_Received(var dt):
	if stun_received:
		velocity = Vector2(0,0);
		stun_time -=dt
		if(stun_time <= 0):
			stun_time = 0.75
			stun_received = false
