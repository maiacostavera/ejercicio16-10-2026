extends Node

# Este script es un Autoload (se agrega en Proyecto > Configuracion del
# proyecto > Autoload, con el nombre "Game"). Al ser Autoload esta siempre
# cargado, asi que desde cualquier otro script puedo escribir Game.puntaje
# y funciona.
#
# Lo use para guardar las cosas que necesitan ver varios scripts a la vez:
# el puntaje lo suma el enemigo cuando muere, pero lo muestra el HUD, y si
# no fuera por aca no se como harian para hablarse.

var puntaje = 0
var oleada = 0
var perdio = false

# Se prende y apaga con F3. Muestra el estado de cada personaje arriba de la
# cabeza. Lo agregue para poder mostrar en la entrega que la maquina de
# estados anda de verdad.
var ver_estados = false


func _ready():
	# Cuando el jugador muere pauso el juego con get_tree().paused = true.
	# Si no pongo esto, este script tambien se pausa y despues no puedo
	# reiniciar la partida. Me paso y tarde un rato en darme cuenta.
	process_mode = Node.PROCESS_MODE_ALWAYS


func _input(evento):
	if evento.is_action_pressed("ver_estados"):
		ver_estados = not ver_estados


func sumar_puntos(cantidad):
	puntaje = puntaje + cantidad


func terminar_juego():
	if perdio:
		return
	perdio = true
	get_tree().paused = true


func reiniciar():
	get_tree().paused = false
	puntaje = 0
	oleada = 0
	perdio = false
	get_tree().reload_current_scene()
