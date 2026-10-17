extends Estado

# ESTADO ATACAR (solo los enemigos de cuerpo a cuerpo)
#
# El golpe pasa una sola vez, en el entrar(). Despues se queda quieto un
# ratito antes de volver a perseguir. Esa pausa es lo que te da tiempo a
# escaparte, si no es imposible.
#
# Ojo: la espera larga entre golpe y golpe NO esta aca, esta en el enemigo,
# porque tiene que seguir bajando mientras persigue. Por eso Perseguir
# pregunta puede_atacar() antes de mandarte a este estado.
#
# De aca puede pasar a: Perseguir y Muerto.

var tiempo_que_queda = 0.0


func entrar():
	tiempo_que_queda = 0.28
	entidad.pegar()


func actualizar(delta):
	entidad.mirar_al_jugador()
	entidad.frenar(delta)

	tiempo_que_queda = tiempo_que_queda - delta
	if tiempo_que_queda <= 0.0:
		cambiar_a("Perseguir")
