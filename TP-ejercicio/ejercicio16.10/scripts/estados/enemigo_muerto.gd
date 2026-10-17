extends Estado

# ESTADO MUERTO (enemigo)
#
# Deja la mancha de sangre, suma los puntos y se borra con queue_free().
# No sale para ningun lado.
#
# Igual que con el jugador, a este estado lo fuerza recibir_danio() cuando la
# vida llega a cero.


func entrar():
	entidad.morir()
