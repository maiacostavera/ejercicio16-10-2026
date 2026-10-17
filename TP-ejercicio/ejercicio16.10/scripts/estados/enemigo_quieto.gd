extends Estado

# ESTADO QUIETO (enemigo)
#
# No hay a quien perseguir: o todavia no aparecio el jugador, o la partida
# ya termino. Se queda frenado esperando.
#
# De aca puede pasar a: Perseguir y Muerto.


func actualizar(delta):
	entidad.frenar(delta)

	if entidad.hay_jugador():
		cambiar_a("Perseguir")
