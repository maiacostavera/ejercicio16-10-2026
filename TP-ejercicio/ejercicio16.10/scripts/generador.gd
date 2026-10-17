extends Node

# EL GENERADOR DE OLEADAS
#
# Se encarga de ir largando enemigos. Cuando no queda ninguno vivo, espera
# unos segundos y arranca la oleada siguiente, cada vez con mas enemigos.
#
# Lo hice con contadores de tiempo comunes en vez de usar nodos Timer porque
# me resulto mas facil de seguir leyendo el codigo de arriba a abajo.

# Los tipos de enemigo que hay. Cada uno usa un personaje distinto del pack.
# El "offset" es lo mismo que en el jugador: cuanto hay que correr el sprite
# para que el personaje gire bien y no de vueltas raras.
const TIPOS = {
	"zombie": {
		"tipo": 0,   # 0 = cuerpo a cuerpo
		"sprite": preload("res://assets/zoimbie1_hold.png"),
		"offset": 1.0,
		"vida": 55, "velocidad": 125.0, "danio": 12, "puntos": 10, "escala": 1.0,
	},
	"zombie_rapido": {
		"tipo": 0,
		"sprite": preload("res://assets/zoimbie1_hold.png"),
		"offset": 1.0,
		"vida": 34, "velocidad": 205.0, "danio": 9, "puntos": 14, "escala": 0.8,
	},
	"robot": {
		"tipo": 1,   # 1 = dispara de lejos
		"sprite": preload("res://assets/robot1_gun.png"),
		"offset": 8.0,
		"vida": 50, "velocidad": 115.0, "danio": 10, "puntos": 18, "escala": 1.0,
		"distancia": 330.0, "espera": 1.3, "danio_bala": 10,
	},
	"soldado": {
		"tipo": 1,
		"sprite": preload("res://assets/soldier1_machine.png"),
		"offset": 8.0,
		"vida": 65, "velocidad": 130.0, "danio": 12, "puntos": 22, "escala": 1.0,
		"distancia": 280.0, "espera": 0.85, "danio_bala": 8,
	},
}

@export var escena_enemigo: PackedScene
@export var escena_bala: PackedScene

var tiempo_para_la_oleada = 3.0
var faltan_aparecer = []
var tiempo_para_el_proximo = 0.0
var lugares = []


func _ready():
	add_to_group("generador")
	# Espero un frame para que el nivel ya este armado y pueda leerle los
	# lugares donde aparecen los enemigos.
	await get_tree().process_frame

	var nivel = get_tree().get_first_node_in_group("nivel")
	if nivel != null:
		lugares = nivel.donde_aparecen_los_enemigos


func _process(delta):
	if Game.perdio:
		return

	if faltan_aparecer.size() > 0:
		# Todavia estoy largando los enemigos de esta oleada, de a uno.
		tiempo_para_el_proximo = tiempo_para_el_proximo - delta
		if tiempo_para_el_proximo <= 0.0:
			_crear_enemigo(faltan_aparecer.pop_back())
			tiempo_para_el_proximo = 0.4
	else:
		# Ya los largue a todos. Espero a que no quede ninguno vivo.
		if get_tree().get_nodes_in_group("enemigos").size() == 0:
			tiempo_para_la_oleada = tiempo_para_la_oleada - delta
			if tiempo_para_la_oleada <= 0.0:
				_empezar_oleada()


func _empezar_oleada():
	Game.oleada = Game.oleada + 1
	tiempo_para_la_oleada = 4.0
	faltan_aparecer = _armar_la_lista(Game.oleada)


# Arma la lista de enemigos de la oleada. Cuanto mas avanzada, mas enemigos
# y mas dificiles.
func _armar_la_lista(numero_de_oleada):
	var lista = []
	var cuantos = 4 + numero_de_oleada * 2

	for i in range(cuantos):
		var suerte = randf()

		if numero_de_oleada >= 3 and suerte < 0.25:
			lista.append("soldado")
		elif numero_de_oleada >= 2 and suerte < 0.45:
			lista.append("robot")
		elif numero_de_oleada >= 2 and suerte < 0.65:
			lista.append("zombie_rapido")
		else:
			lista.append("zombie")

	return lista


func _crear_enemigo(nombre_del_tipo):
	if escena_enemigo == null or lugares.size() == 0:
		return

	var datos = TIPOS[nombre_del_tipo]
	var enemigo = escena_enemigo.instantiate()

	# Le paso los datos ANTES de agregarlo a la escena, porque despues de
	# add_child() ya corrio su _ready() y algunos no le llegan a tiempo.
	enemigo.tipo = datos["tipo"]
	enemigo.vida_maxima = datos["vida"]
	enemigo.velocidad = datos["velocidad"]
	enemigo.danio_de_golpe = datos["danio"]
	enemigo.puntos_que_da = datos["puntos"]
	enemigo.escena_bala = escena_bala

	if datos["tipo"] == 1:
		enemigo.distancia_para_disparar = datos["distancia"]
		enemigo.espera_entre_tiros = datos["espera"]
		enemigo.danio_de_bala = datos["danio_bala"]

	enemigo.global_position = _elegir_lugar()

	get_tree().get_first_node_in_group("personajes").add_child(enemigo)

	# El sprite se lo pongo despues de agregarlo, porque recien ahi el nodo
	# $Cuerpo/Sprite existe de verdad.
	enemigo.sprite.texture = datos["sprite"]
	enemigo.sprite.offset.x = datos["offset"]
	enemigo.sprite.scale = Vector2.ONE * datos["escala"]

	# Aparece creciendo, queda lindo.
	enemigo.scale = Vector2.ZERO
	var tween = create_tween()
	tween.tween_property(enemigo, "scale", Vector2.ONE, 0.22)


# Elijo el lugar que este mas lejos del jugador, asi no aparecen encima.
func _elegir_lugar():
	var jugador = get_tree().get_first_node_in_group("jugador")
	if jugador == null:
		return lugares.pick_random()

	var lejanos = []
	for lugar in lugares:
		if lugar.distance_to(jugador.global_position) > 300:
			lejanos.append(lugar)

	if lejanos.size() > 0:
		return lejanos.pick_random()
	return lugares.pick_random()
