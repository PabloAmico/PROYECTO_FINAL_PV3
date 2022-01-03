extends KinematicBody2D


export(int) var SPEED: int = 40
export(int) var SPEED_PATROL: int = 40


export(int) var life : int = 100
export(int) var max_life : int = 100
var velocity: Vector2 = Vector2.ZERO
export(int) var damage : int = 30

var cooldown_attack = 1
var attack = false
var finish_attack = false

var hit = false
var change_hit = false
var time_hit = 0.075

#pathFinding
var path: Array = []
var levelNavigation: Navigation2D = null
var player = null
var player_hear = null;

var player_enter = false;
var player_enter_hear = false;

#Player_Attack

var player_zone_Attack = false

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

#var sounds
var cooldown_sound_idle = 0

var cooldown_sound_pursuit = 0

var play_sound_Attack = false

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
	if finish_attack:
		cooldown_attack -= delta
		if cooldown_attack <= 0:
			finish_attack = false
			attack = false
			cooldown_attack = 1
			play_sound_Attack = false
	Control_Sounds(delta)

	if change_hit:
		if hit:
			$Sprite.material.set_shader_param("col", 1)
		else:
			$Sprite.material.set_shader_param("col", 0)
	
	if hit:
		time_hit -= delta
		print(time_hit)
		if time_hit <= 0:
			time_hit = 0.075
			hit = false
			change_hit = true


func _physics_process(delta):
	if player_enter && player != null:
		#yield(get_tree(), "idle_frame")
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
	Control_Animation()


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
	if(life > 0):
		
		hit = true
		change_hit = true
		life -= Damage
		player_enter = true
		print("el daño sufrido fue = " + String(Damage))
		print(life)
		if life > 0:
			var aux = get_tree().get_nodes_in_group("HealtBar")[1]
			aux._on_target_health(name)

		if(life <= 0):
			var aux = get_tree().get_nodes_in_group("HealtBar")[1]
			aux.target = null
			Kill_Zombie()
	else:
		var aux = get_tree().get_nodes_in_group("HealtBar")[1]
		aux.target = null
		Kill_Zombie()
	
func Kill_Zombie():
	queue_free()


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

func Control_Sounds(var delta):
	cooldown_sound_idle -= delta
	cooldown_sound_pursuit -= delta
	if (velocity == Vector2(0,0) || assign_Dir) && !player_enter:
		if cooldown_sound_idle <= 0:
			Sound_Idle_or_patrol()
			cooldown_sound_idle = 7
	elif player_zone_Attack && !finish_attack && !play_sound_Attack:
		Sound_Attack()
		
	elif player_enter:
		if cooldown_sound_pursuit <= 0:
			#print("Reproduje en pursuit")
			Sound_Pursuit()
			cooldown_sound_pursuit = 5
	

func Sound_Idle_or_patrol():
	var sound = (randi() % 10) - 1
	match sound:
		0:
			$Audio/Idle_1.play()
		1:
			$Audio/Idle_2.play()
		2:
			$Audio/Idle_3.play()
		3:
			$Audio/Idle_4.play()
		4:
			$Audio/Idle_5.play()
		5:
			$Audio/Idle_6.play()
		6:
			$Audio/Idle_7.play()
		7:
			var aux = (randi() % 3)
			if aux == 1:
				$Audio/Brains_1.play()
			else:
				$Audio/Idle_1.play()
		8:
			var aux = (randi() % 3)
			if aux == 1:
				$Audio/Brains_2.play()
			else:
				$Audio/Idle_3.play()
	pass

func Sound_Pursuit():
	var sound = (randi() % 5) - 1

	match sound:
		0:
			$Audio/Pursuit_1.play()
		1:
			$Audio/Pursuit_2.play()
		2:
			$Audio/Pursuit_3.play()
		3:
			$Audio/Pursuit_4.play()
	pass

func Sound_Attack():
	play_sound_Attack = true
	var sound = (randi() % 4) -1
	match sound:
		0:
			$Audio/Attack_1.play()
		1:
			$Audio/Attack_2.play()
		2:
			$Audio/Attack_3.play()
	pass
			

func Control_Animation():
	if velocity == Vector2(0,0):
		$AnimacionZombie.stop()
	elif player_zone_Attack && !finish_attack:
		$AnimacionZombie.play("Zombie_Attack")
		
	elif assign_Dir:
		$AnimacionZombie.play("Zombie_Idle")
	elif player_enter:
		$AnimacionZombie.play("Zombie_Move")
	
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
	if body.is_in_group("Player"):
		body.Reduce_life(damage)
		attack = true
	pass # Replace with function body.



func _on_Colision_Con_Jugador_body_entered(body):
	if body.is_in_group("Player"):
		if !body.is_dead:
			player_zone_Attack = true
			print("Entre")
		
		

func _on_Colision_Con_Jugador_body_exited(body):
	if body.is_in_group("Player"):
		player_zone_Attack = false
		pass



func _on_AnimacionZombie_animation_finished(anim_name):
	if anim_name == "Zombie_Attack":
		finish_attack = true
		print("termine")
	pass



func _on_AreaColision_area_entered(area):
	if area.is_in_group("Player"):
		player_enter = true
	pass # Replace with function body.
