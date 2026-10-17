extends Node2D

# EL NIVEL
#
# En vez de dibujar el mapa a mano con un TileMap, lo escribi como texto.
# Cada letra es una celda de 64x64 pixeles. Me parecio mucho mas comodo:
# cambio una letra y ya tengo otro mapa, sin abrir el editor.
#
# Que significa cada simbolo:
#   #  pared          .  piso de madera
#   S  aca aparecen los enemigos
#   P  aca empieza el jugador
#   c  cajon      t  mesa      s  sillon     (estos tres frenan el paso)
#   h  botiquin   a  cajon de municion

const TAMANIO_CELDA = 64

const MAPA = [
	"########################",
	"#......................#",
	"#..S.....######.....S..#",
	"#........#....#........#",
	"#...###..#....#..###...#",
	"#...###..........###...#",
	"#......................#",
	"#.....c.......P........#",
	"#......................#",
	"#..##.......h......##..#",
	"#..##..............##..#",
	"#.........####.........#",
	"#....t....#..#....s....#",
	"#..S......#..#......S..#",
	"#.........a............#",
	"########################",
]

# Los tiles que uso del pack de Kenney. Los numeros son los nombres de los
# archivos que estan en assets/kenney/PNG/Tiles/
const TILE_PARED = preload("res://assets/tile_86.png")
const TILE_PISO = preload("res://assets/tile_43.png")

# Los objetos que frenan el paso: el dibujo y el tamanio del circulo que les
# pongo de colision.
const OBJETOS = {
	"c": {"imagen": preload("res://assets/tile_129.png"), "radio": 25.0},
	"t": {"imagen": preload("res://assets/tile_501.png"), "radio": 27.0},
	"s": {"imagen": preload("res://assets/tile_478.png"), "radio": 25.0},
}

# Estas tres las lee el resto del juego.
var donde_empieza_el_jugador = Vector2(300, 300)
var donde_aparecen_los_enemigos = []
var donde_van_los_items = []

var ancho_en_pixeles = 0
var alto_en_pixeles = 0

var _filas = 0
var _columnas = 0


func _ready():
	add_to_group("nivel")

	_filas = MAPA.size()
	_columnas = MAPA[0].length()
	ancho_en_pixeles = _columnas * TAMANIO_CELDA
	alto_en_pixeles = _filas * TAMANIO_CELDA

	_revisar_que_el_mapa_este_bien()
	_leer_el_mapa()
	_poner_los_objetos()


# Si edito el mapa y me como una letra, todo queda corrido y despues no
# entiendo por que. Esto me avisa por consola en que fila me equivoque.
func _revisar_que_el_mapa_este_bien():
	for f in range(_filas):
		if MAPA[f].length() != _columnas:
			print("ERROR en el mapa: la fila ", f, " tiene ", MAPA[f].length(),
				" letras y tendria que tener ", _columnas)


func _leer_el_mapa():
	for f in range(_filas):
		for c in range(_columnas):
			var letra = MAPA[f][c]
			var posicion = Vector2(c, f) * TAMANIO_CELDA
			var centro = posicion + Vector2(TAMANIO_CELDA, TAMANIO_CELDA) / 2

			if letra == "#":
				_poner_pared(posicion)
			else:
				_poner_piso(posicion)

			# Lo que no es pared ni piso son marcas: me guardo donde estan.
			if letra == "P":
				donde_empieza_el_jugador = centro
			elif letra == "S":
				donde_aparecen_los_enemigos.append(centro)
			elif letra == "h":
				donde_van_los_items.append({"posicion": centro, "clase": "vida"})
			elif letra == "a":
				donde_van_los_items.append({"posicion": centro, "clase": "municion"})


func _poner_piso(posicion):
	var imagen = Sprite2D.new()
	imagen.texture = TILE_PISO
	imagen.centered = false   # si no, lo dibuja corrido medio tile
	imagen.position = posicion
	imagen.z_index = -2
	add_child(imagen)


# Cada pared es un StaticBody2D con su dibujo y su cuadrado de colision.
# Se que seria mas prolijo juntar las paredes que estan pegadas en un solo
# cuerpo, pero asi es mas facil de entender y el juego anda igual de rapido.
func _poner_pared(posicion):
	var pared = StaticBody2D.new()
	pared.position = posicion + Vector2(TAMANIO_CELDA, TAMANIO_CELDA) / 2
	pared.collision_layer = 1
	pared.collision_mask = 0
	add_child(pared)

	var imagen = Sprite2D.new()
	imagen.texture = TILE_PARED
	pared.add_child(imagen)

	var colision = CollisionShape2D.new()
	var cuadrado = RectangleShape2D.new()
	cuadrado.size = Vector2(TAMANIO_CELDA, TAMANIO_CELDA)
	colision.shape = cuadrado
	pared.add_child(colision)


func _poner_los_objetos():
	for f in range(_filas):
		for c in range(_columnas):
			var letra = MAPA[f][c]
			if not OBJETOS.has(letra):
				continue

			var datos = OBJETOS[letra]
			var objeto = StaticBody2D.new()
			objeto.position = Vector2(c, f) * TAMANIO_CELDA + Vector2(32, 32)
			objeto.collision_layer = 1
			objeto.collision_mask = 0
			add_child(objeto)

			var imagen = Sprite2D.new()
			imagen.texture = datos["imagen"]
			objeto.add_child(imagen)

			var colision = CollisionShape2D.new()
			var circulo = CircleShape2D.new()
			circulo.radius = datos["radio"]
			colision.shape = circulo
			objeto.add_child(colision)
