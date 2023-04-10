extends KinematicBody2D

var Move_Dir = Vector2(0,0)
var Shoot_Dir = Vector2.ZERO

export var Move_Speed = 250
export var Move_Run = 325 #Se mueve un 30% mas rapido
export var run = false
var deadzone = 0.3
var rs_look = Vector2()
var velocity



var Num_Arma_Equipada

var target

export var Ataque = false

var cooldown_punch = false

var cooldown_knife = false

var time_Run = 0

export var is_dead = false

var attack_melee = false



#Array de Animaciones
var Animaciones_Idle = ["Flashlight_Idle", "knife_idle", "Pistol_Idle", "Shotgun_Idle", "Rifle_Idle"]
var Animaciones_Move = ["Flashlight_Move", "knife_move", "Pistol_Move", "Shotgun_Move", "Rifle_Move"]
var Animaciones_Attack = ["flshlight_attack", "knife_attack", "Pistol_Shoot", "Shotgun_Shoot", "Rifle__Shoot"]
var Animaciones_Shoot = [null, null, "Pistol_Shoot", "Shotgun_Shoot", "Rifle__Shoot"]
var Animaciones_Reload = [null, null, "Pistol_Reload", "Shotgun_Reload", "Rifle_Reload"]
var Animaciones_MeleeAttack = ["flshlight_attack","knife_attack","Pistol_Attack", "Shotgun_Attack", "Rifle_Attack"]

#Daño de las armas
export(int) var Damage_pistol: int = 0
export(int) var Damage_shotgun: int = 0
export(int) var Damage_rifle: int = 0
export(int) var Damage_punch: int = 0
export(int) var Damage_knife: int = 0

var damage_weapons = []



var reloading = false

#Dispersion de las armas y daño de la escopeta a la distancia
var rotation_Raycast = 0

var dispersion_change = false

var disp_Rifle = false

var time_trigger = 0

var time_less_dispersion = 1

#Indoor

export(bool) var indoor: bool = false

#Keys

var Keys = ["none"];

#GUI

var GUI = null;

#////////////////////////////////////////////////////////////////////////////////////////////////////////////////
func _init():
	PlayerStatsGlobal.Load_Data();

func _ready():
	GUI = get_tree().get_nodes_in_group("Canvas")[0]
	
	if(PlayerStatsGlobal.life == 0):
		PlayerStatsGlobal.life = PlayerStatsGlobal.max_life;
	rotation_Raycast = $RayCast2D.rotation_degrees
	PlayerStatsGlobal.Armas_Disponibles = [PlayerStatsGlobal.Desarmado, PlayerStatsGlobal.Tiene_Cuchillo, PlayerStatsGlobal.Tiene_Pistola, PlayerStatsGlobal.Tiene_Escopeta, PlayerStatsGlobal.Tiene_Rifle]
	Num_Arma_Equipada = 0
	target = true
	$RayCast2D.enabled = false
	damage_weapons = [null, null, Damage_pistol, Damage_shotgun, Damage_rifle]
	PlayerStatsGlobal.cant_max_weapons = [null,null, PlayerStatsGlobal.cant_max_bullet_pistol, PlayerStatsGlobal.cant_max_bullet_shotgun, PlayerStatsGlobal.cant_max_bullet_rifle]
	PlayerStatsGlobal.bullets_current_weapons = [null, null, PlayerStatsGlobal.bullets_current_pistol, PlayerStatsGlobal.bullets_current_shotgun, PlayerStatsGlobal.bullets_current_rifle] #
	PlayerStatsGlobal.bullets_in_magazine_weapons = [null, null, PlayerStatsGlobal.bullets_in_magazine_pistol, PlayerStatsGlobal.bullets_in_magazine_shotgun, PlayerStatsGlobal.bullets_in_magazine_rifle] #balas que tiene el cargador
	PlayerStatsGlobal.max_magazine_weapons = [null, null, PlayerStatsGlobal.max_magazine_pistol, PlayerStatsGlobal.max_magazine_shotgun, PlayerStatsGlobal.max_magazine_rifle]	#Cantidad maxima de balas por cargador
	
	

func _process(delta):
	if PlayerStatsGlobal.life > 0:
		if disp_Rifle:
			time_less_dispersion -= delta
			if(time_less_dispersion <= 0):
				time_less_dispersion = 1;
				disp_Rifle = false
				$RayCast2D.rotation_degrees = 270
				$Laser/Raycast_Laser.rotation_degrees =270
				time_trigger = 0
			pass

func _physics_process(delta):
	if PlayerStatsGlobal.life > 0:
		if Num_Arma_Equipada > 1:
			$Laser.visible = true
			
		else:
			$Laser.visible = false

		Aim()
		
		_joypads()
		
		if(run):
			velocity = Move_Dir * Move_Run
			time_Run += delta
		else:
			velocity = Move_Dir * Move_Speed
			if time_Run >= 3:
				$Audio/Stop_Run.play()
				time_Run = 0
			else:
				time_Run = 0
		velocity = move_and_slide(velocity)

		_Set_Animations()


func rslook():
	rs_look.y = Input.get_joy_axis(0, JOY_AXIS_3)
	rs_look.x = Input.get_joy_axis(0, JOY_AXIS_2)
	if rs_look.length() >= deadzone:
		rotation = rs_look.angle()


func _Set_Animations():
	if !Ataque && !reloading && !attack_melee:
		if velocity == Vector2(0,0):
			$AnimationPlayer.play(Animaciones_Idle[Num_Arma_Equipada])
		else:
			$AnimationPlayer.play(Animaciones_Move[Num_Arma_Equipada])
			
	elif Ataque:
		$AnimationPlayer.play(Animaciones_Attack[Num_Arma_Equipada])
	elif reloading && Num_Arma_Equipada > 1:
		$AnimationPlayer.play(Animaciones_Reload[Num_Arma_Equipada])
	elif attack_melee && Num_Arma_Equipada > 1:
		$AnimationPlayer.play(Animaciones_MeleeAttack[Num_Arma_Equipada])
		
	

func _joypads():
	velocity = Vector2.ZERO
	Move_Dir.x = -Input.get_action_strength("Mover_Izquierda") + Input.get_action_strength("Mover_Derecha")
	Move_Dir.y = -Input.get_action_strength("Mover_Arriba") + Input.get_action_strength("Mover_Abajo")
	rslook() #Movimiento en circulo del personaje.
	
	if Input.is_action_just_pressed("Recargar") && Num_Arma_Equipada > 1:
		if PlayerStatsGlobal.max_magazine_weapons[Num_Arma_Equipada] > PlayerStatsGlobal.bullets_in_magazine_weapons[Num_Arma_Equipada]:
			Reload()
	
	if Input.is_action_just_pressed("Atacar"):
		if Num_Arma_Equipada != 4:
			if(Num_Arma_Equipada > 1 && !reloading):
				if (PlayerStatsGlobal.bullets_in_magazine_weapons[Num_Arma_Equipada] > 0):
					Ataque = true
					$RayCast2D.enabled = true
					PlayerStatsGlobal.bullets_in_magazine_weapons[Num_Arma_Equipada] -= 1
					Sounds_Weapons()
				elif !reloading:
					Reload()
			elif Num_Arma_Equipada <= 1:
				Sounds_Weapons()
				Ataque = true
		
	if Input.is_action_just_pressed("Arma_Siguiente"):
		if(!Ataque && !reloading):
			Change_Arma_UP()
	
	if Input.is_action_just_pressed("Arma_Anterior"):
		if(!Ataque && !reloading):
			Change_Arma_DOWN()
	
	if Input.is_action_pressed("Correr"):
		run = true
	else:
		run = false;
	
	if Input.is_action_pressed("Atacar"):
		if(Num_Arma_Equipada == 4 && !Ataque):
			if(PlayerStatsGlobal.bullets_in_magazine_weapons[4] > 0):
				time_trigger += 0.4
				if(time_trigger >= 1.6):
					Dispersion_Rifle(time_trigger)
				Ataque = true
				$RayCast2D.enabled = true
				PlayerStatsGlobal.bullets_in_magazine_weapons[4] -= 1
				Sounds_Weapons()
			elif !reloading:
				Reload()
	
	if Input.is_action_just_released("Atacar"):
		if(Num_Arma_Equipada == 4):
			disp_Rifle = true
		

	if Input.is_action_just_pressed("Ataque_melee"):
		
		attack_melee = true
		pass
	
	
	#if Input.action_release("Atacar"):
		
func Sounds_Weapons():
	match Num_Arma_Equipada:
		0:
			if !cooldown_punch:
				$Audio/Punch.play()
				cooldown_punch = true
		1:
				if !cooldown_knife:
					$Audio/Knife.play()
					cooldown_knife = true
		2:
			$Audio/Pistol.play()
		
		3:
			$Audio/Shotgun.play()
		
		4:
			$Audio/Rifle.play()
		


func _on_AnimationPlayer_animation_finished(anim_name):
	if (anim_name == Animaciones_Reload[2]) || (anim_name == Animaciones_Reload[3]) || (anim_name == Animaciones_Reload[4]):
		Assign_Bullets()
		reloading = false
	if (Num_Arma_Equipada != PlayerStatsGlobal.Armas_Disponibles.size()):
		Ataque = false
	$RayCast2D.enabled = false
	target = true
	if anim_name == Animaciones_Attack[0]:
		cooldown_punch = false
	
	if anim_name == Animaciones_Attack[1]:
		cooldown_knife = false

	if anim_name == Animaciones_MeleeAttack[Num_Arma_Equipada]:
		attack_melee = false
	pass # Replace with function body.

func Set_Arma_Equipada():
	PlayerStatsGlobal.Arma_Equipada[Num_Arma_Equipada] = true
	for i in range(PlayerStatsGlobal.Arma_Equipada.size()-1):
		if(i != Num_Arma_Equipada):
			PlayerStatsGlobal.Arma_Equipada[i] = false


func Change_Arma_UP():
	
	var Bandera
	while(!Bandera):
		Num_Arma_Equipada = Num_Arma_Equipada +1
		if (Num_Arma_Equipada == PlayerStatsGlobal.Armas_Disponibles.size()):
			Num_Arma_Equipada = 0
			Bandera = true
		elif(PlayerStatsGlobal.Armas_Disponibles[Num_Arma_Equipada]):
			Bandera = true
	Set_Arma_Equipada()

func Change_Arma_DOWN():
	var Bandera
	while(!Bandera):
		Num_Arma_Equipada = Num_Arma_Equipada - 1
		if(Num_Arma_Equipada < 0):
			Num_Arma_Equipada = 5
		elif(PlayerStatsGlobal.Armas_Disponibles[Num_Arma_Equipada]):
			Bandera = true
	Set_Arma_Equipada()
	

func Aim():
	if $RayCast2D.is_colliding() && target:
		target = false
		var col = $RayCast2D.get_collider()
		if(col.is_in_group("enemigos")):
			Particles(true)
			if(Num_Arma_Equipada == 3):
				var distancia = global_position.distance_to(col.global_position)
				col.Reduce_Life(Dispersion_Shotgun(distancia))
			else:
				col.Reduce_Life(damage_weapons[Num_Arma_Equipada])
		else:
			Particles(false)
			pass

func Particles(var hit):	#Si es verdadero emite la particula de sangre. si es falso emite la de colicion con objetos
	var position_shoot = $RayCast2D.get_collision_point()
	if hit:
		$Particula_Sangre.global_position = position_shoot
		$Particula_Sangre.restart()
		
	else:
		$Particula_Disparo.global_position = position_shoot
		$Particula_Disparo.restart()

func Reload():
	if !reloading && PlayerStatsGlobal.bullets_current_weapons[Num_Arma_Equipada] > 0:
		$Audio/Reload.play()
		#$AnimationPlayer.play(Animaciones_Reload[Num_Arma_Equipada])
		reloading = true
	else:
		reloading = false
		
	
func Assign_Bullets():
	if PlayerStatsGlobal.bullets_current_weapons[Num_Arma_Equipada] > 0:
		if PlayerStatsGlobal.bullets_current_weapons[Num_Arma_Equipada] >= PlayerStatsGlobal.max_magazine_weapons[Num_Arma_Equipada]:
			var _aux_bullets = PlayerStatsGlobal.bullets_in_magazine_weapons[Num_Arma_Equipada]
			PlayerStatsGlobal.bullets_in_magazine_weapons[Num_Arma_Equipada] = PlayerStatsGlobal.max_magazine_weapons[Num_Arma_Equipada]
			PlayerStatsGlobal.bullets_current_weapons[Num_Arma_Equipada] -= PlayerStatsGlobal.max_magazine_weapons[Num_Arma_Equipada] - _aux_bullets
		elif (PlayerStatsGlobal.bullets_in_magazine_weapons[Num_Arma_Equipada] + PlayerStatsGlobal.bullets_current_weapons[Num_Arma_Equipada]) <= PlayerStatsGlobal.max_magazine_weapons[Num_Arma_Equipada]:
			PlayerStatsGlobal.bullets_in_magazine_weapons[Num_Arma_Equipada] += PlayerStatsGlobal.bullets_current_weapons[Num_Arma_Equipada]
			PlayerStatsGlobal.bullets_current_weapons[Num_Arma_Equipada] = 0
		else:
			PlayerStatsGlobal.bullets_current_weapons[Num_Arma_Equipada] -= (PlayerStatsGlobal.max_magazine_weapons[Num_Arma_Equipada] - PlayerStatsGlobal.bullets_in_magazine_weapons[Num_Arma_Equipada])
			PlayerStatsGlobal.bullets_in_magazine_weapons[Num_Arma_Equipada] = PlayerStatsGlobal.max_magazine_weapons[Num_Arma_Equipada]
	reloading = false
		
func Check_Magazine():
	if PlayerStatsGlobal.max_magazine_weapons[Num_Arma_Equipada] <= 0:
		Reload()

func Dispersion_Shotgun(var distancia):

	if distancia < 400:
		
		return damage_weapons[3] * 2
	elif distancia >= 400 && distancia < 750:
		return damage_weapons[3]
	elif distancia >= 750 && distancia <= 1000:
		return int(damage_weapons[3] / rand_range(1,2.5))
	elif distancia > 1000:
		return int(damage_weapons[3] / rand_range(3,5))

func Dispersion_Rifle(var time_press):
	disp_Rifle = false
	if(dispersion_change):
		$RayCast2D.rotation_degrees -= time_press
		$Laser/Raycast_Laser.rotation_degrees -= time_press
		dispersion_change = false
	else:
		$RayCast2D.rotation_degrees  += time_press
		$Laser/Raycast_Laser.rotation_degrees += time_press
		dispersion_change = true
	pass
	



func _on_hitarea_body_entered(body):
	if body.is_in_group("enemigos"):
		if Num_Arma_Equipada == 0:
			body.Reduce_Life(Damage_punch)
			body.punch_received = true
		elif Num_Arma_Equipada == 1:
			body.Reduce_Life(Damage_knife)
			body.stun_received = true
		elif attack_melee:
			body.Reduce_Life(30)
			body.punch_received = true

			
func Reduce_life(var Damage):
	if PlayerStatsGlobal.life > 0:
		PlayerStatsGlobal.life -= Damage
		Sound_damage()
		if(PlayerStatsGlobal.life <= 0):
			Kill_Player()
			PlayerStatsGlobal.Save_Data()
			GUI.get_node("ColorRect").visible = true;
			
	else:
		Kill_Player()
		PlayerStatsGlobal.Save_Data()
		GUI.get_node("ColorRect").visible = true;


func Sound_damage():
	var select = (randi() % 4) -1
	match select:
		0:
			$Audio/Damage_1.play()
		1:
			$Audio/Damage_2.play()
		2: 
			$Audio/Damage_3.play()



func Kill_Player():
	is_dead = true
	$Audio/Death.play()
	
func Add_Life(health):
	PlayerStatsGlobal.life += health;
	if(PlayerStatsGlobal.life > PlayerStatsGlobal.max_life):
		PlayerStatsGlobal.life = PlayerStatsGlobal.max_life


func Add_Bullets(ammo, type):
	match type:
		"Pistol":
				if !PlayerStatsGlobal.Armas_Disponibles[2]:
					PlayerStatsGlobal.Armas_Disponibles[2] = true;
					#PlayerStatsGlobal.Tiene_Pistola = true;
					
				PlayerStatsGlobal.bullets_current_weapons[2] += ammo
				if PlayerStatsGlobal.bullets_current_weapons[2] > PlayerStatsGlobal.cant_max_bullet_pistol:
					PlayerStatsGlobal.bullets_current_weapons[2] = PlayerStatsGlobal.cant_max_bullet_pistol;
					
		
		"Shotgun":
				if !PlayerStatsGlobal.Armas_Disponibles[3]:
					PlayerStatsGlobal.Armas_Disponibles[3] = true;
					#PlayerStatsGlobal.Tiene_Escopeta = true;
				PlayerStatsGlobal.bullets_current_weapons[3] += ammo
				if(PlayerStatsGlobal.bullets_current_weapons[3] > PlayerStatsGlobal.cant_max_bullet_shotgun):
					PlayerStatsGlobal.bullets_current_weapons[3] = PlayerStatsGlobal.cant_max_bullet_shotgun;

		"Rifle":
				if !PlayerStatsGlobal.Armas_Disponibles[4]:
					PlayerStatsGlobal.Armas_Disponibles[4] = true;
					#PlayerStatsGlobal.Tiene_Rifle = true;
				PlayerStatsGlobal.bullets_current_weapons[4] += ammo
				if(PlayerStatsGlobal.bullets_current_weapons[4] > PlayerStatsGlobal.cant_max_bullet_rifle):
					PlayerStatsGlobal.bullets_current_weapons[4] = PlayerStatsGlobal.cant_max_bullet_rifle;

func Get_Key(key):
	var Have_Key = false;
	var Iterator = 0
	
	while !Have_Key && Iterator < Keys.size():
		if(key == Keys[Iterator]):
			Have_Key = true;
		Iterator += 1;
		
	return Have_Key;


func Add_Key(key):
	Keys.append(key);

func Enabled_Knife():
	if !PlayerStatsGlobal.Armas_Disponibles[1]:
		PlayerStatsGlobal.Armas_Disponibles[1] = true;
