extends Estado

# ESTADO DISPARAR (solo los enemigos de distancia)
#
# Trata de quedarse a una distancia comoda y tira:
#   - si estoy muy cerca, retrocede
#   - si estoy muy lejos, se acerca
#   - si esta justo, se mueve de costado para no ser un blanco fijo
#
# De aca puede pasar a: Perseguir (si lo perdio de vista o se alejo mucho),
# Quieto y Muerto.


func actualizar(delta):
	if not entidad.hay_jugador():
		cambiar_a("Quieto")
		return

	entidad.mirar_al_jugador()

	var hacia_el = entidad.direccion_al_jugador()
	var distancia = entidad.distancia_al_jugador
	var comoda = entidad.distancia_para_disparar
	var direccion

	if distancia < comoda * 0.6:
		direccion = -hacia_el
	elif distancia > comoda:
		direccion = hacia_el
	else:
		# orthogonal() devuelve el vector girado 90 grados. Lo use para que
		# camine en circulo alrededor del jugador.
		direccion = hacia_el.orthogonal()

	entidad.mover(direccion, delta)

	if entidad.puede_atacar():
		entidad.tirar_un_tiro()

	# Si lo perdio de vista o se le fue muy lejos, vuelve a perseguir.
	if not entidad.lo_veo or distancia > comoda * 1.5:
		cambiar_a("Perseguir")
