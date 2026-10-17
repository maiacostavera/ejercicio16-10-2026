extends CanvasLayer

# EL HUD (los carteles de la pantalla)
#
# En vez de usar señales, en cada frame leo los valores del jugador y de
# Game y los escribo en los Labels. Es la forma mas facil que encontre y
# para este juego alcanza de sobra.

@onready var barra_vida = $Todo/BarraVida
@onready var texto_vida = $Todo/BarraVida/TextoVida
@onready var icono_arma = $Todo/IconoArma
@onready var texto_arma = $Todo/TextoArma
@onready var texto_balas = $Todo/TextoBalas
@onready var texto_oleada = $Todo/TextoOleada
@onready var texto_puntaje = $Todo/TextoPuntaje
@onready var pantalla_final = $Todo/PantallaFinal
@onready var texto_final = $Todo/PantallaFinal/Cartel/Margen/Lista/TextoFinal
@onready var boton = $Todo/PantallaFinal/Cartel/Margen/Lista/Boton

var jugador = null


func _ready():
	# Sin esto el HUD se pausa junto con el juego y el boton de reiniciar
	# no se puede apretar.
	process_mode = Node.PROCESS_MODE_ALWAYS

	pantalla_final.visible = false
	boton.pressed.connect(Game.reiniciar)


func _process(_delta):
	# Busco al jugador cada vez porque cuando el HUD arranca todavia no existe.
	if jugador == null or not is_instance_valid(jugador):
		jugador = get_tree().get_first_node_in_group("jugador")

	texto_oleada.text = "Oleada  " + str(Game.oleada)
	texto_puntaje.text = "Puntaje  " + str(Game.puntaje)

	if jugador != null:
		_mostrar_datos_del_jugador()

	if Game.perdio and not pantalla_final.visible:
		_mostrar_pantalla_final()


func _mostrar_datos_del_jugador():
	barra_vida.max_value = jugador.vida_maxima
	barra_vida.value = jugador.vida
	texto_vida.text = str(jugador.vida) + " / " + str(jugador.vida_maxima)

	var arma = jugador.arma_actual()
	icono_arma.texture = arma["icono"]
	texto_arma.text = arma["nombre"]

	var en_cargador = jugador.balas_en_cargador[jugador.arma]
	var reserva = jugador.balas_de_reserva[jugador.arma]

	if reserva < 0:
		texto_balas.text = str(en_cargador) + " / " + str(arma["cargador"])
	else:
		texto_balas.text = str(en_cargador) + " / " + str(arma["cargador"]) + "   (" + str(reserva) + ")"


func _mostrar_pantalla_final():
	texto_final.text = "Llegaste a la oleada " + str(Game.oleada) + " con " + str(Game.puntaje) + " puntos."
	pantalla_final.visible = true


func _input(evento):
	if Game.perdio and evento.is_action_pressed("reiniciar"):
		Game.reiniciar()
