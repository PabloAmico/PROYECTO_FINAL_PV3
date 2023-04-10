extends Control

onready var health_bar = $Bar

var target = null

var target_array = null
export var name_enemy = false
export var target_player = false

func _ready():
	if target_player:
		target = PlayerStatsGlobal
		
		
		_on_max_health_updated()
	else:
		health_bar.tint_progress = Color(0.5,0.129,0.160, 1)
	pass # Replace with function body.

func _on_health_updated():
	
	if target != null:
		
		if target.life <= 0:
			self.visible = false
		else:
			health_bar.value = target.life
	else:
		self.visible = false


func _on_max_health_updated():
	if target != null:
		health_bar.max_value = target.max_life

func _on_target_health(var name):
	target_array = get_tree().get_nodes_in_group("enemigos")
	for enemy in target_array:
		if enemy.name == name:
			target = enemy
		pass
	_on_max_health_updated()
	if self.visible == false:
		self.visible = true

func _process(delta):
	if target != null:
		_on_health_updated()
	else:
		self.visible =  false
