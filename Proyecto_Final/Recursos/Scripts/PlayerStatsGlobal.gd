extends Node

export(int) var life : int = 120

export(int) var max_life : int = 120

#Variables booleanas de armas y desarmado
export var Desarmado = true
export var Tiene_Pistola = false
export var Pistola_Equipada = false
export var Tiene_Escopeta = false
export var Escopeta_Equipada = false
export var Tiene_Rifle = false
export var Rifle_Equipado = false
export var Tiene_Cuchillo = false
export var Cuchillo_Equipado = false
var Armas_Disponibles = [Desarmado, Tiene_Cuchillo, Tiene_Pistola, Tiene_Escopeta, Tiene_Rifle]
var Nombre_Arma_Equipada = ["Linterna","Cuchillo","Pistola","Escopeta","Rifle"]
var Arma_Equipada = [Desarmado, Cuchillo_Equipado, Pistola_Equipada, Escopeta_Equipada, Rifle_Equipado]
var Tiempo_Entre_Disparos = false;


#Cantidad maxima de balas que se pueden llevar.
export(int) var cant_max_bullet_pistol: int = 96 # 8 cargadores de 12 balas.
export(int) var cant_max_bullet_shotgun: int = 40 # 5 cargadores de 8 balas.
export(int) var cant_max_bullet_rifle : int = 160 # 8 cargadores de 20 balas.

var cant_max_weapons = []

#Balas disponibles.
export(int) var bullets_current_pistol: int = 0
export(int) var bullets_current_shotgun: int = 0
export(int) var bullets_current_rifle: int = 0

var bullets_current_weapons = []

#Cargadores de las armas.

var bullets_in_magazine_pistol = 12
var bullets_in_magazine_shotgun = 8
var bullets_in_magazine_rifle = 20

var bullets_in_magazine_weapons = []

#capacidad maxima cargadores

var max_magazine_pistol = 12
var max_magazine_shotgun = 8
var max_magazine_rifle = 20

var max_magazine_weapons = []


var current_level = 1;


var data_player = {
	life = 120,
	max_life = 120,
	#position_x = 0.0,
	#position_y = 0.0,
	Desarmado = true,
	Tiene_Pistola = false,
	Pistola_Equipada = false,
	Tiene_Escopeta = false,
	Escopeta_Equipada = false,
	Tiene_Rifle = false,
	Rifle_Equipado = false,
	Tiene_Cuchillo = false,
	Cuchillo_Equipado = false,
	bullets_in_magazine_pistol = 12,
	bullets_in_magazine_shotgun = 8,
	bullets_in_magazine_rifle = 20,
	bullets_current_pistol = 0,
	bullets_current_shotgun = 0,
	bullets_current_rifle = 0,
	current_level = 1
}



func _ready():
	var path = Directory.new();
	if(!path.dir_exists("user://Save")):
		
		path.open("user://");
		path.make_dir("user://Save");
		

func Restart_Data():
	PlayerStatsGlobal.Armas_Disponibles = [PlayerStatsGlobal.Desarmado, PlayerStatsGlobal.Tiene_Cuchillo, PlayerStatsGlobal.Tiene_Pistola, PlayerStatsGlobal.Tiene_Escopeta, PlayerStatsGlobal.Tiene_Rifle]
	PlayerStatsGlobal.cant_max_weapons = [null,null, PlayerStatsGlobal.cant_max_bullet_pistol, PlayerStatsGlobal.cant_max_bullet_shotgun, PlayerStatsGlobal.cant_max_bullet_rifle]
	PlayerStatsGlobal.bullets_current_weapons = [null, null, PlayerStatsGlobal.bullets_current_pistol, PlayerStatsGlobal.bullets_current_shotgun, PlayerStatsGlobal.bullets_current_rifle] #
	PlayerStatsGlobal.bullets_in_magazine_weapons = [null, null, PlayerStatsGlobal.bullets_in_magazine_pistol, PlayerStatsGlobal.bullets_in_magazine_shotgun, PlayerStatsGlobal.bullets_in_magazine_rifle] #balas que tiene el cargador
	PlayerStatsGlobal.max_magazine_weapons = [null, null, PlayerStatsGlobal.max_magazine_pistol, PlayerStatsGlobal.max_magazine_shotgun, PlayerStatsGlobal.max_magazine_rifle]	#Cantidad maxima de balas por cargador
	var _save = File.new();
	_save.open("user://Save/data.save", File.WRITE);
	
	var data_save = data_player;
	Data_save(data_save);

	_save.store_line(to_json(data_save));

	_save.close();
	pass

func Save_Data():
	var _save = File.new();
	_save.open("user://Save/data.save", File.WRITE);
	
	var data_save = data_player;
	Data_save(data_save);

	_save.store_line(to_json(data_save));

	_save.close();

func Load_Data():
	var _load = File.new() 
	if(!_load.file_exists("user://Save/data.save")):
		print("No hay partidas guardadas")
		return
	_load.open("user://Save/data.save", File.READ);

	var load_data = data_player;

	if(!_load.eof_reached()):
		var data_prov = parse_json(_load.get_line());
		if(data_prov != null):
			load_data = data_prov;
	
	Data_load(load_data);
	_load.close()

func Data_save(var data_save):
	data_save.life = life;
	data_save.max_life = max_life;
	#data_save.position_x = get_tree().get_nodes_in_group("Player")[0].global_position.x
	#data_save.position_y = get_tree().get_nodes_in_group("Player")[0].global_position.y
	data_save.Desarmado = Armas_Disponibles[0]
	data_save.Tiene_Pistola = Armas_Disponibles[2]
	data_save.Pistola_Equipada = Pistola_Equipada
	data_save.Tiene_Escopeta = Armas_Disponibles[3]
	data_save.Escopeta_Equipada = Escopeta_Equipada
	data_save.Tiene_Rifle = Armas_Disponibles[4]
	data_save.Rifle_Equipado = Rifle_Equipado
	data_save.Tiene_Cuchillo = Armas_Disponibles[1]
	data_save.Cuchillo_Equipado = Cuchillo_Equipado
	data_save.bullets_in_magazine_pistol = bullets_in_magazine_weapons[2]
	data_save.bullets_in_magazine_shotgun =  bullets_in_magazine_weapons[3]
	data_save.bullets_in_magazine_rifle =  bullets_in_magazine_weapons[4]
	data_save.bullets_current_pistol = bullets_current_weapons[2]
	data_save.bullets_current_shotgun = bullets_current_weapons[3]
	data_save.bullets_current_rifle = bullets_current_weapons[4]
	data_save.current_level = current_level;

func Data_load(var load_data):
	life = load_data.life;
	max_life = load_data.max_life;
	#get_tree().get_nodes_in_group("Player")[0].global_position.x = load_data.position_x
	#get_tree().get_nodes_in_group("Player")[0].global_position.y = load_data.position_y
	Desarmado = load_data.Desarmado
	Tiene_Pistola = load_data.Tiene_Pistola
	Pistola_Equipada = load_data.Pistola_Equipada
	Tiene_Escopeta = load_data.Tiene_Escopeta
	Escopeta_Equipada = load_data.Escopeta_Equipada
	Tiene_Rifle = load_data.Tiene_Rifle
	Rifle_Equipado = load_data.Rifle_Equipado
	Tiene_Cuchillo = load_data.Tiene_Cuchillo
	Cuchillo_Equipado = load_data.Cuchillo_Equipado
	bullets_in_magazine_pistol = load_data.bullets_in_magazine_pistol
	bullets_in_magazine_shotgun = load_data.bullets_in_magazine_shotgun
	bullets_in_magazine_rifle = load_data.bullets_in_magazine_rifle
	bullets_current_pistol = load_data.bullets_current_pistol
	bullets_current_shotgun = load_data.bullets_current_shotgun
	bullets_current_rifle = load_data.bullets_current_rifle
	current_level = load_data.current_level
