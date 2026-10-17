extends CharacterBody2D

# EL ENEMIGO
#
# Funciona igual que el jugador: este script sabe COMO hacer las cosas
# (perseguir, pegar, disparar) y los estados deciden CUANDO.
#
# Hay dos tipos y los distingo con la variable "tipo":
#   0 = CUERPO  -> te corre y te pega de cerca (los zombies)
#   1 = DISTANCIA -> se queda lejos y te dispara (robots y soldados)
#
# Los dos comparten los estados Quieto, Perseguir y Muerto. Lo unico distinto
# es que uno pasa a Atacar y el otro a Disparar. Eso fue lo que mas me gusto
# de hacerlo con estados: no tuve que escribir dos enemigos separados.

const CUERPO = 0
const DISTANCIA = 1

@export var tipo = CUERPO
@export var vida_maxima = 60
@export var velocidad = 135.0
@export var puntos_que_da = 10

@export_group("Pegar de cerca")
@export var danio_de_golpe = 12
@export var distancia_para_pegar = 46.0
@export var espera_entre_golpes = 0.8

@export_group("Disparar")
@export var escena_bala: PackedScene
@export var distancia_para_disparar = 330.0
@export var espera_entre_tiros = 1.25
@export var danio_de_bala = 10

@onready var cuerpo = $Cuerpo
@onready var sprite = $Cuerpo/Sprite
@onready var canio = $Cuerpo/Canio
@onready var maquina = $MaquinaDeEstados

var vida = 60
var espera_ataque = 0.0

# Estas tres las calculo una vez por frame y las leen los estados, asi no
# hago la misma cuenta cuatro veces.
var jugador = null
var distancia_al_jugador = 0.0
var lo_veo = false

# De donde vino el ultimo tiro. Lo uso para que la mancha de sangre salga
# para el lado correcto.
var ultimo_golpe = Vector2.ZERO


func _ready():
	add_to_group("enemigos")
	vida = vida_maxima
	maquina.iniciar(self)
	# Nota: en la escena del enemigo le puse la mascara de colision 5, que es
	# la capa 1 (mundo) + la capa 3 (enemigos). Al principio solo chocaban con
	# las paredes y entonces se amontonaban todos en el mismo lugar y parecian
	# uno solo. Haciendo que choquen entre ellos quedan repartidos sin que yo
	# tenga que programar nada.


func _physics_process(delta):
	espera_ataque = max(0.0, espera_ataque - delta)

	jugador = get_tree().get_first_node_in_group("jugador")

	if jugador == null or Game.perdio:
		lo_veo = false
		distancia_al_jugador = 99999.0
		return

	distancia_al_jugador = global_position.distance_to(jugador.global_position)
	lo_veo = _puedo_verlo()


# =========================================================================
# Cosas que usan los estados
# =========================================================================

func hay_jugador():
	return jugador != null and not Game.perdio


func direccion_al_jugador():
	return (jugador.global_position - global_position).normalized()


func mirar_al_jugador():
	if jugador != null:
		cuerpo.rotation = direccion_al_jugador().angle()


func mover(direccion, delta):
	velocity = velocity.move_toward(direccion * velocidad, 900.0 * delta)
	move_and_slide()


func frenar(delta):
	velocity = velocity.move_toward(Vector2.ZERO, 900.0 * delta)
	move_and_slide()


func puede_atacar():
	return espera_ataque <= 0.0


# Golpe cuerpo a cuerpo.
func pegar():
	if jugador == null:
		return

	espera_ataque = espera_entre_golpes
	jugador.recibir_danio(danio_de_golpe, direccion_al_jugador())

	# Un estiron para que se note el golpe.
	var tween = create_tween()
	tween.tween_property(cuerpo, "scale", Vector2(1.15, 0.9), 0.08)
	tween.tween_property(cuerpo, "scale", Vector2.ONE, 0.12)


func tirar_un_tiro():
	if escena_bala == null or jugador == null:
		return

	espera_ataque = espera_entre_tiros

	# Les pongo bastante desvio a proposito, si no es imposible esquivarlos.
	var desvio = deg_to_rad(6.0)
	var angulo = direccion_al_jugador().angle() + randf_range(-desvio, desvio)

	var bala = escena_bala.instantiate()
	get_tree().get_first_node_in_group("balas").add_child(bala)
	bala.disparar_desde(canio.global_position, angulo, danio_de_bala, "enemigos")


# Lo llama el estado Muerto.
func morir():
	_dejar_mancha()
	Game.sumar_puntos(puntos_que_da)
	queue_free()


# =========================================================================
# Esto lo llaman las balas del jugador
# =========================================================================

func recibir_danio(cantidad, de_donde = Vector2.ZERO):
	if vida <= 0:
		return

	vida = vida - cantidad
	ultimo_golpe = de_donde

	# Empujoncito del balazo.
	velocity = velocity + de_donde.normalized() * 140.0

	# Parpadeo blanco.
	sprite.modulate = Color(1.6, 1.0, 1.0)
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.18)

	if vida <= 0:
		maquina.cambiar_a("Muerto")


# =========================================================================

# Tiro un rayo desde el enemigo hasta el jugador y miro si choca con algo.
# Si choca es porque hay una pared en el medio y no lo ve.
# Esto lo saque de la documentacion de Godot (PhysicsRayQueryParameters2D),
# solo con la capa 1 que es la del mundo.
func _puedo_verlo():
	var espacio = get_world_2d().direct_space_state
	var consulta = PhysicsRayQueryParameters2D.create(
		global_position, jugador.global_position, 1, [get_rid()]
	)
	var choque = espacio.intersect_ray(consulta)
	return choque.is_empty()


func _dejar_mancha():
	var nivel = get_tree().get_first_node_in_group("nivel")
	if nivel == null:
		return

	var mancha = Sprite2D.new()
	mancha.texture = preload("res://assets/tile_320.png")
	mancha.global_position = global_position + ultimo_golpe.normalized() * 10.0
	mancha.rotation = randf() * TAU
	mancha.modulate = Color(0.55, 0.1, 0.12, 0.85)
	mancha.z_index = -1   # para que quede abajo de los personajes
	nivel.add_child(mancha)
