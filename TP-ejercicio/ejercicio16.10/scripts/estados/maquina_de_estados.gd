class_name MaquinaDeEstados
extends Node

# Esta es la maquina de estados. Va como nodo hijo del jugador y del enemigo,
# y cada estado es un nodo hijo de ella:
#
#   Jugador
#   └── MaquinaDeEstados
#       ├── Quieto        <- el primer hijo es con el que arranca
#       ├── Caminar
#       ├── Esquivar
#       ├── Recargar
#       └── Muerto
#
# Lo bueno de hacerlo con nodos es que lo veo dibujado en el editor y no me
# pierdo. Y como solo le aviso al estado activo, los otros no gastan nada.

var estado_actual = null
var etiqueta = null  # el cartelito de debug, si el personaje tiene uno


# Esto lo llama el jugador o el enemigo al final de su _ready().
#
# Al principio lo hacia en el _ready() de este mismo script, pero no andaba:
# los hijos hacen _ready() ANTES que el padre, entonces cuando la maquina
# arrancaba el jugador todavia no habia terminado de prepararse y me tiraba
# errores de null. Haciendolo al reves (que el jugador avise cuando esta listo)
# se soluciono.
func iniciar(duenio):
	for hijo in get_children():
		hijo.entidad = duenio
		hijo.pedir_cambio.connect(cambiar_a)

	etiqueta = duenio.get_node_or_null("Etiqueta")

	# El primer hijo es el estado inicial.
	estado_actual = get_child(0)
	estado_actual.entrar()
	_actualizar_etiqueta()


func _physics_process(delta):
	if estado_actual == null:
		return

	estado_actual.actualizar(delta)

	if etiqueta != null:
		etiqueta.visible = Game.ver_estados


# Cambia de estado. El nombre tiene que ser igual al del nodo hijo.
func cambiar_a(nombre_del_estado):
	var nuevo = get_node_or_null(nombre_del_estado)

	if nuevo == null:
		# Si me equivoco escribiendo el nombre prefiero que me avise por consola
		# antes que el juego se rompa sin decir nada.
		print("ERROR: no existe el estado '", nombre_del_estado, "' en ", owner.name)
		return

	estado_actual.salir()
	estado_actual = nuevo
	estado_actual.entrar()
	_actualizar_etiqueta()


# Sirve para preguntar desde afuera en que estado estoy.
func esta_en(nombre_del_estado):
	return estado_actual != null and estado_actual.name == nombre_del_estado


func _actualizar_etiqueta():
	if etiqueta != null:
		etiqueta.text = estado_actual.name
