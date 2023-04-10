extends KinematicBody2D

export(int) var SPEED: int = 40
export(int) var SPEED_PATROL: int = 40


export(int) var life : int = 100
export(int) var max_life : int = 100
var velocity: Vector2 = Vector2.ZERO
export(int) var damage : int = 30

var pistol = false
var shotgun = false
var rifle = false

var player_enter = false;
var player_enter_hear = false;
var player_enter_vision = false;
var player_enter_shoot = false;

var animation_array = []

var equipment = 1;

#patrol

var assign_patrol = false;
var in_patrol = 0;
var assign_Dir = false;

#pathFinding
var path: Array = []
var levelNavigation: Navigation2D = null
var player = null
var player_hear = null;
var player_pursuit = null

#Variables varias
var _attack = false;
var finish_attack = true
export(float) var MAX_cooldown_attack;
var CURRENT_cooldown_attack;
var hit = false;
var change_hit = false;

#Punch received

export(bool) var punch_received: bool = false
var punch_time = 0.3
var player_punch = null

#stab received
export(bool) var stun_received: bool = false
var stun_time = 0.75

#Instanciar objetos.
var obj_Prefab = load("res://Recursos/Escenas_Objetos/ItemsAndGuns.tscn")
var obj_Instance = null;

var Level = 1;
var Control = null;

# Called when the node enters the scene tree for the first time.
func _ready():
	CURRENT_cooldown_attack = MAX_cooldown_attack;
	Set_Equip(equipment)
	yield(get_tree(), "idle_frame")
	var tree = get_tree()

	randomize()
			
	if tree.has_group("LevelNavigation"):
		levelNavigation = tree.get_nodes_in_group("LevelNavigation")[0]
			
	if tree.has_group("Player"):
		player = tree.get_nodes_in_group("Player")[0]
	pass # Replace with function body.

	if tree.has_group("Control"):
		Control = tree.get_nodes_in_group("Control")[0]

func _process(delta):
	Hear_Player()
	Vision_Player()
	Hear_Shoot_Player()
	if finish_attack && player_enter:
		CURRENT_cooldown_attack -= delta;
		if CURRENT_cooldown_attack <= 0:
			Can_Shoot();
			finish_attack = false;
			CURRENT_cooldown_attack = MAX_cooldown_attack;
	


func _physics_process(delta):
	if player_enter && player != null:
		look_at(player.global_position)

	if player and levelNavigation:
		if player_enter: #&& !punch_received && !stun_received:
			generate_path()
			navigate()

	idle_Patrol()
	move()
	Control_Animations()

func navigate():
	if player_enter:
		if path.size() > 0:
			velocity = global_position.direction_to(path[1]) * SPEED

			if global_position == path[0]:
				path.pop_front()
		
	
	
func generate_path():
	
	if levelNavigation != null and player != null:
		path = levelNavigation.get_simple_path(global_position, player.global_position, false)

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


func move():
	if player_enter: 
		if player !=null && Check_Distance() > 500:	
			velocity = move_and_slide(velocity)
	else:
		velocity = move_and_slide(velocity)
	

		#Funcion que sirve para chequear si el jugador esta en realidad visible y no esta detras de una pared
func check_Visibility():
	if player_pursuit != null:	
		$check_visibility/RayCast2D.add_exception(self)
		$check_visibility/RayCast2D.look_at(player_pursuit.global_position);
		var col = $check_visibility/RayCast2D.get_collider()
		
		if col != null:
			if col.is_in_group("Player"):
				player_enter = true;
				
	

func Check_Distance():
	if player != null:
		return position.distance_to(player.position)
	pass

func Set_Equip(var equip):
	match equip:
		1:
			equipment = 1
			pistol = true;
			damage = 10
			MAX_cooldown_attack = 0.75;
			animation_array = ["SOLDIER_Pistol_Idle", "SOLDIER_Pistol_Move", "SOLDIER_Pistol_Reload", "SOLDIER_Pistol_Shoot"]
		2:
			equipment = 2
			shotgun = true;
			damage = 25
			MAX_cooldown_attack = 1;
			animation_array = ["SOLDIER_Shotgun_Idle", "SOLDIER_Shotgun_Move", "SOLDIER_Shotgun_Reload", "SOLDIER_Shotgun_Shoot"]
		3:
			equipment = 3
			rifle = true;
			damage = 15
			MAX_cooldown_attack = 0.5;
			animation_array = ["SOLDIER_Rifle_Idle", "SOLDIER_Rifle_Move", "SOLDIER_Rifle_Reload", "SOLDIER_Rifle_Shoot"]
	pass


func Can_Shoot():
	finish_attack = true;
	if equipment == 1:
		
		if $RayCast2D.is_colliding():
			var col = $RayCast2D.get_collider()
			if(col.is_in_group("Player")):
				
				_attack = true;
				if PlayerStatsGlobal.life > 0:
					col.Reduce_life(10);
			else:
				_attack = true;

	pass	

func Shoot():
	if _attack:
		
		pass

func Control_Animations():
	if _attack:
		$AnimationPlayer.play(animation_array[3])
		
	elif velocity.x != 0 || velocity.y !=0:
		$AnimationPlayer.play(animation_array[1])
	else:
		$AnimationPlayer.play(animation_array[0])
		
	pass

func Hear_Player():
	if player_hear:
		if player_hear.run && player_enter_hear:
			player_enter = true
	pass

func Vision_Player():
	if player_enter_vision:
		check_Visibility()	

func Hear_Shoot_Player():
	if player_enter_shoot:
		player_enter = true	

func Punch_Received(var dt):
	if(punch_received):
		velocity = Vector2((position.x * cos(player_punch.rotation_degrees)*1.1), (position.y * sin(player_punch.rotation_degrees)*1.1))
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

func Reduce_Life(var Damage):
	if(life > 0):
		hit = true
		change_hit = true
		life -= Damage
		player_enter = true
		if life > 0:
			var aux = get_tree().get_nodes_in_group("HealtBar")[1]
			aux._on_target_health(name)

		if(life <= 0):
			var aux = get_tree().get_nodes_in_group("HealtBar")[1]
			aux.target = null
			Kill_Soldier()
	else:
		var aux = get_tree().get_nodes_in_group("HealtBar")[1]
		aux.target = null
		Kill_Soldier()

func Drop_Object():
	if player != null:
		
		if PlayerStatsGlobal.life <= PlayerStatsGlobal.max_life / 2:
			var numRandom = (randi()%10) + 1
			
			if(numRandom > 4):
				obj_Instance = obj_Prefab.instance()
				get_parent().add_child(obj_Instance);
				obj_Instance.Set_Integer(0);	#Asigno vida.
				obj_Instance.global_position = self.global_position;
			elif player.Num_Arma_Equipada > 1:
				obj_Instance = obj_Prefab.instance()
				get_parent().add_child(obj_Instance);
				obj_Instance.Set_Integer(player.Num_Arma_Equipada);
				obj_Instance.global_position = self.global_position;
		elif PlayerStatsGlobal.life < PlayerStatsGlobal.max_life:
				var numRandom = (randi()%10) + 1
				if(numRandom > 7):
					obj_Instance = obj_Prefab.instance()
					get_parent().add_child(obj_Instance);
					obj_Instance.Set_Integer(0);	#Asigno vida.
					obj_Instance.global_position = self.global_position;
				elif player.Num_Arma_Equipada > 1:
					obj_Instance = obj_Prefab.instance()
					get_parent().add_child(obj_Instance);
					obj_Instance.Set_Integer(player.Num_Arma_Equipada);
					obj_Instance.global_position = self.global_position;
		else:
			if player.Num_Arma_Equipada > 1:
				obj_Instance = obj_Prefab.instance()
				get_parent().add_child(obj_Instance);
				obj_Instance.Set_Integer(player.Num_Arma_Equipada);
				obj_Instance.global_position = self.global_position;

func Kill_Soldier():
	Drop_Object();
	if(Level == 2):
		Control.enemies.erase(self)
		
	queue_free();

func _on_Zona_De_Vision_body_entered(body):
	if body.is_in_group("Player"):
		player_enter_vision = true
		player_pursuit = body;
	pass # Replace with function body.


func _on_Zona_De_Vision_body_exited(body):
	if body.is_in_group("Player"):
		player_enter = false
		player_enter_vision = false
		player_pursuit = null;
	pass # Replace with function body.


func _on_Zona_De_Escucha_body_entered(body):
	if body.is_in_group("Player"):
		player_hear = body
		player_enter_hear = true
	pass # Replace with function body.


func _on_Zona_De_Escucha_body_exited(body):
	if body.is_in_group("Player"):
		player_hear = null
		player_enter_hear = false
	pass # Replace with function body.


func _on_Area2D_area_entered(area):
	if area.is_in_group("Player_Sound"):
		player_enter_shoot = true
	pass # Replace with function body.


func _on_Area2D_area_exited(area):
	if area.is_in_group("Player_Sound"):
		player_enter_shoot = false
	pass # Replace with function body.


func _on_AnimationPlayer_animation_finished(anim_name:String):
	if anim_name == animation_array[3]:
	
		finish_attack = true;
		_attack = false;
		pass
	pass # Replace with function body.
