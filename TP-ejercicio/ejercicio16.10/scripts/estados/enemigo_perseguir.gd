extends Estado

# ESTADO PERSEGUIR
#
# Va derecho hacia el jugador. Lo usan los dos tipos de enemigo.
#
# Si choca contra una pared, move_and_slide() lo hace resbalar por el borde,
# asi que la mayoria de las veces termina encontrando la vuelta. No es el
# camino mas inteligente (para eso habria que usar navegacion de verdad, que
# todavia no se), pero para el tamanio del mapa funciona bien.
#
# De aca puede pasar a: Quieto, Atacar (si es de cuerpo), Disparar (si es de
# distancia) y Muerto.


func actualizar(delta):
	if not entidad.hay_jugador():
		cambiar_a("Quieto")
		return

	entidad.mirar_al_jugador()
	entidad.mover(entidad.direccion_al_jugador(), delta)

	if entidad.tipo == entidad.CUERPO:
		# Los zombies atacan cuando te tienen al lado.
		if entidad.distancia_al_jugador <= entidad.distancia_para_pegar and entidad.puede_atacar():
			cambiar_a("Atacar")
	else:
		# Los que disparan se frenan cuando te ven y estan a tiro.
		if entidad.lo_veo and entidad.distancia_al_jugador <= entidad.distancia_para_disparar:
			cambiar_a("Disparar")
