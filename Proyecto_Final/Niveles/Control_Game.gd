extends Node2D
var rand = RandomNumberGenerator.new()
var enemyPrefab_1 = load("res://Recursos/Escenas_Objetos/Zombie.tscn")
var enemyPrefab_2 = load("res://Recursos/Escenas_Objetos/Soldier.tscn")

var enemies = []
var enemy = null;

var screen_size = 0

var positions_spawn = [];

var hordes = 0;

var GUI = null;

var position_player = null;

func _init():
	PlayerStatsGlobal.Load_Data();
	

func _ready():
	#PlayerStatsGlobal.Load_Data();
	
	GUI = get_tree().get_nodes_in_group("Canvas")[0]
	GUI.get_node("Remaining").visible = true;
	GUI.get_node("Waves").visible = true;
	positions_spawn = get_node("Positions_Spawn").get_children();
	position_player = get_tree().get_nodes_in_group("Player")[0].global_position;
	Instantiate_Enemies();
	
	pass 


func _process(delta):
	Instantiate_Enemies();
	for i in enemies.size():
		if(enemies[i] == null):
			enemies.erase(null);
			pass
	GUI.get_node("Remaining").text = "Enemigos Restantes: " + String(enemies.size());
	GUI.get_node("Waves").text = "Horda N°: " + String(hordes);



func Instantiate_Enemies():
	if enemies.empty():
		get_tree().get_nodes_in_group("Player")[0].global_position = position_player;
		hordes +=1;
		if hordes < 4:
			var integer = 0;
			for i in hordes *5:
				enemy = enemyPrefab_1.instance();
				add_child(enemy);
				enemy.global_position = positions_spawn[integer].global_position;
				enemies.append(enemy);
				enemy.Level = 2;
				integer +=1
				

				enemy = enemyPrefab_2.instance();
				add_child(enemy);
				enemy.global_position = positions_spawn[integer].global_position;
				enemies.append(enemy);
				enemy.Level = 2;
				integer += 1;
			
		else:
			get_tree().change_scene("res://Niveles/Escena Victoria.tscn");
			
	pass
