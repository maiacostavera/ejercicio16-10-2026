extends Node2D

# ESCENA PRINCIPAL
#
# Es la que arranca cuando apreto F5. Lo unico que hace es armar la partida:
# pone al jugador donde dice el nivel y reparte los botiquines.
#
# Los nodos vacios (Personajes, Balas) estan para tener todo ordenado y no
# que me queden 50 nodos sueltos colgando de la escena.

@export var escena_jugador: PackedScene
@export var escena_item: PackedScene

@onready var nivel = $Nivel
@onready var personajes = $Personajes
@onready var balas = $Balas


func _ready():
	# Los pongo en grupos para que los otros scripts los encuentren sin tener
	# que escribir la ruta completa tipo get_node("../../Balas"), que si
	# despues muevo un nodo se rompe todo.
	personajes.add_to_group("personajes")
	balas.add_to_group("balas")

	_crear_jugador()
	_crear_items()


func _crear_jugador():
	if escena_jugador == null:
		print("ERROR: falta poner la escena del jugador en el inspector")
		return

	var jugador = escena_jugador.instantiate()
	personajes.add_child(jugador)
	jugador.global_position = nivel.donde_empieza_el_jugador


func _crear_items():
	if escena_item == null:
		return

	for datos in nivel.donde_van_los_items:
		var item = escena_item.instantiate()
		# La clase se la pongo antes del add_child porque el _ready() del item
		# la usa para elegir el dibujo.
		item.clase = datos["clase"]
		personajes.add_child(item)
		item.global_position = datos["posicion"]


func _input(evento):
	if evento.is_action_pressed("salir"):
		get_tree().quit()
