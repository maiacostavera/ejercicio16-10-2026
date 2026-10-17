extends Estado

# ESTADO MUERTO
#
# Es el ultimo estado, no sale para ningun lado: se sale reiniciando la
# partida con Enter.
#
# A este estado no se llega con una transicion normal. Lo fuerza la funcion
# recibir_danio() del jugador llamando a maquina.cambiar_a("Muerto"), porque
# morirse no es algo que el estado actual pueda decidir.


func entrar():
	entidad.morir()
