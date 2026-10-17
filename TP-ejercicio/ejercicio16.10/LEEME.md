# Trabajo Práctico - Shooter cenital en Godot 4

Juego de disparos visto desde arriba, hecho con Godot 4.4 y los gráficos
gratuitos de [Kenney](https://kenney.nl/assets/top-down-shooter) (licencia CC0,
o sea que se pueden usar libremente).

El pack original trae 580 imágenes, pero en `assets/` dejé solamente las 18 que
el juego usa de verdad, para que el proyecto no pese al pepe y se pueda subir a
GitHub sin problema. Si querés usar más, se bajan del link de arriba y se
copian en esa misma carpeta.

## Cómo abrirlo

1. Abrir Godot y en el Administrador de proyectos tocar **Importar**.
2. Buscar el archivo `project.godot` de esta carpeta y abrirlo.
3. La primera vez tarda un poco porque importa todas las imágenes del pack.
4. Apretar **F5** para jugar.

## Controles

| Qué hace | Tecla |
|---|---|
| Moverse | `W` `A` `S` `D` o las flechitas |
| Apuntar | el mouse |
| Disparar | click izquierdo (la ametralladora se puede dejar apretado) |
| Recargar | `R` |
| Esquivar | `Espacio` |
| Cambiar de arma | `1` `2` `3` |
| Volver a jugar | `Enter` cuando perdés |
| **Ver los estados** | `F3` |
| Salir | `Esc` |

## De qué se trata

Sos un tipo en un galpón y van apareciendo oleadas de enemigos. Cada oleada
trae más y de tipos más difíciles. Hay tres armas, un botiquín y un cajón de
munición que se vuelven a llenar cada tanto.

Hay dos clases de enemigos:

- **Zombies**: te corren y te pegan cuando te alcanzan. Hay uno normal y otro
  más chico que es más rápido pero aguanta menos.
- **Robots y soldados**: se quedan a distancia y te disparan, pero solamente
  si te están viendo. Si te metés atrás de una pared dejan de tirar.

## La máquina de estados (esta es la parte principal del TP)

La hice con **nodos**: cada estado es un nodo hijo del nodo `MaquinaDeEstados`,
y se ve dibujada en el editor. Me pareció la forma más clara porque la podés
mirar en el árbol de la escena en vez de tener que leer el código para saber
qué estados hay.

```
Jugador                        Enemigo
├── Cuerpo                     ├── Cuerpo
├── Colision                   ├── Colision
├── Camara                     ├── MaquinaDeEstados
├── MaquinaDeEstados           │   ├── Quieto      <- el primero es el inicial
│   ├── Quieto                 │   ├── Perseguir
│   ├── Caminar                │   ├── Atacar
│   ├── Esquivar               │   ├── Disparar
│   ├── Recargar               │   └── Muerto
│   └── Muerto                 └── Etiqueta
└── Etiqueta
```

Hay dos archivos base, en `scripts/estados/`:

- **`estado.gd`**: la clase de la que heredan todos los estados. Tiene cuatro
  funciones (`entrar()`, `salir()`, `actualizar(delta)` y `cambiar_a()`) y
  cada estado completa las que necesita.
- **`maquina_de_estados.gd`**: guarda cuál es el estado activo y es el único
  al que le avisa en cada frame. Los otros estados no gastan nada mientras
  están apagados.

El mismo script de la máquina lo usan el jugador y el enemigo. Lo único que
cambia son los nodos que le cuelgo abajo.

### Transiciones del jugador

| De | A | Cuándo |
|---|---|---|
| Quieto | Caminar | aprieto una tecla de movimiento |
| Caminar | Quieto | suelto las teclas |
| Quieto / Caminar | Recargar | aprieto `R`, o intento disparar sin balas |
| Recargar | Quieto | terminó de recargar, o cambié de arma y se canceló |
| Quieto / Caminar / Recargar | Esquivar | aprieto espacio y no está en espera |
| Esquivar | Quieto o Caminar | se terminó el tiempo del esquive |
| *cualquiera* | Muerto | la vida llega a 0 |

Mientras estoy en **Esquivar** no me pueden pegar y no puedo disparar.
Mientras estoy en **Recargar** me puedo mover y apuntar, pero no disparar.

### Transiciones del enemigo

Los dos tipos comparten `Quieto`, `Perseguir` y `Muerto`. Lo que cambia es que
el zombie pasa a `Atacar` y el robot a `Disparar`. **Eso para mí fue lo mejor
de hacerlo con estados**: no tuve que escribir dos enemigos distintos.

| De | A | Cuándo |
|---|---|---|
| Quieto | Perseguir | aparece el jugador |
| Perseguir / Disparar | Quieto | no hay jugador o terminó la partida |
| Perseguir | Atacar | *(zombie)* lo tiene al lado y el golpe está listo |
| Atacar | Perseguir | terminó la pausa después del golpe |
| Perseguir | Disparar | *(robot)* lo ve y está a distancia de tiro |
| Disparar | Perseguir | lo perdió de vista o se le fue muy lejos |
| *cualquiera* | Muerto | la vida llega a 0 |

### Por qué me sirvió hacerlo así

Antes de la máquina de estados tenía un montón de variables sueltas tipo
`esta_recargando`, `esta_esquivando`, `puede_disparar`, y en cada `if` tenía
que acordarme de preguntar por todas. Me quedó un `_physics_process` larguísimo
y cada vez que agregaba algo rompía otra cosa.

Con los estados:

- **Cada estado es un archivo chiquito** que se lee en 20 segundos.
- **El `salir()` limpia solo.** El estado Esquivar deja al personaje medio
  transparente. Antes me olvidaba de volverlo a la normalidad en alguno de los
  caminos de salida y el personaje quedaba transparente para siempre. Ahora lo
  pongo una sola vez en `salir()` y se arregla siempre, salga por donde salga.
- **Agregar algo nuevo no rompe lo viejo.** Si quiero un estado "Aturdido",
  creo el archivo, lo cuelgo como nodo y listo.

La regla que seguí: **el personaje sabe CÓMO hacer las cosas y el estado decide
CUÁNDO**. Por eso en `jugador.gd` están las funciones `mover()`, `disparar()`,
`terminar_recarga()`, pero ninguna decide nada; eso lo deciden los estados.

**Si apretás `F3` mientras jugás** te aparece arriba de cada personaje el
estado en el que está, en celeste el del jugador y en naranja el de los
enemigos. Lo agregué para poder mostrar que funciona de verdad.

## Archivos del proyecto

```
escenas/
  principal.tscn   la escena que arranca
  jugador.tscn     el jugador, con su cámara y su máquina de estados
  enemigo.tscn     el enemigo (el generador le cambia el sprite y los números)
  bala.tscn        la bala, la usan los dos
  item.tscn        botiquín / cajón de munición
  hud.tscn         los carteles de la pantalla

scripts/
  game.gd          Autoload: puntaje, oleada y si perdí
  principal.gd     arma la partida
  nivel.gd         construye el mapa a partir del texto
  jugador.gd       todo lo que el jugador sabe hacer
  enemigo.gd       todo lo que el enemigo sabe hacer
  generador.gd     va largando las oleadas
  bala.gd          la bala
  item.gd          los objetos que se agarran
  hud.gd           los carteles

  estados/
    estado.gd              clase base
    maquina_de_estados.gd  la máquina
    jugador_quieto.gd   jugador_caminar.gd   jugador_esquivar.gd
    jugador_recargar.gd jugador_muerto.gd
    enemigo_quieto.gd   enemigo_perseguir.gd enemigo_atacar.gd
    enemigo_disparar.gd enemigo_muerto.gd

assets/            las 18 imágenes que uso, + la licencia del pack
.gitignore         para no subir a GitHub la carpeta .godot/
```

Son unos 50 archivos en total. La carpeta `.godot/` que aparece cuando abrís el
proyecto **no hay que subirla**: la genera Godot sola y pesa un montón. Por eso
está el `.gitignore`.

## Cómo está hecho el mapa

En vez de dibujarlo con un TileMap lo escribí como texto, en la constante
`MAPA` de `scripts/nivel.gd`. Cada letra es un cuadradito de 64x64:

| Letra | Qué es |
|---|---|
| `#` | pared |
| `.` | piso |
| `P` | dónde empieza el jugador |
| `S` | dónde aparecen los enemigos |
| `c` `t` `s` | cajón / mesa / sillón (no se puede pasar) |
| `h` `a` | botiquín / cajón de munición |

Para cambiar el mapa alcanza con cambiar las letras. **Todas las filas tienen
que tener la misma cantidad de letras**; si me equivoco, el juego me avisa por
consola en qué fila fue (eso lo agregué porque me pasó y no entendía por qué
se veía todo corrido).

## Cosas que me costaron

1. **Los sprites de Kenney no están centrados.** El personaje tiene el brazo
   y el arma para afuera, entonces el centro del dibujo no es el centro del
   cuerpo. Cuando lo hacía girar parecía que bailaba en vez de girar sobre sí
   mismo. Lo arreglé corriendo el sprite con `offset.x`, probando números hasta
   que quedó bien (están en el diccionario `ARMAS`).

2. **Giraba el personaje entero y se movía la cámara.** Al principio rotaba el
   `CharacterBody2D`, pero como la cámara es hija de él, giraba toda la
   pantalla y mareaba. Lo resolví metiendo el sprite adentro de un nodo
   `Cuerpo` y rotando solo ese nodo.

3. **La máquina arrancaba antes que el jugador.** Los nodos hijos hacen
   `_ready()` antes que el padre, así que la máquina arrancaba cuando el
   jugador todavía no había terminado de prepararse y me tiraba errores de
   null. Lo di vuelta: ahora el jugador llama a `maquina.iniciar(self)` al
   final de su propio `_ready()`.

4. **El juego pausado no me dejaba reiniciar.** Cuando perdés uso
   `get_tree().paused = true`, pero eso también pausaba el HUD y el botón no
   andaba. Se arregla poniéndole `process_mode = PROCESS_MODE_ALWAYS` al HUD
   y al Autoload.

5. **Los enemigos se amontonaban todos en el mismo lugar** y parecía uno solo.
   Era porque solo chocaban con las paredes. Les puse la máscara de colisión
   para que choquen también entre ellos y se repartieron solos.

6. **Las balas se mataban entre enemigos.** Les agregué un "equipo" a las balas
   para que una bala atraviese a los del mismo bando que la disparó.

## Lo que le falta / qué haría después

- Los enemigos van siempre derecho hacia el jugador. Si hay una pared en el
  medio se resbalan por el borde y casi siempre llegan, pero no es que sepan
  dar la vuelta. Para eso habría que usar navegación de verdad
  (`NavigationRegion2D`), que todavía no vi.
- No tiene sonido. El pack de Kenney no trae, habría que bajar otro.
- No guarda el récord entre partidas.
- Me gustaría ponerle una barrita de vida arriba de cada enemigo.
- Un menú de inicio antes de empezar a jugar.

## Créditos

- Gráficos: **Kenney** — [Top-down Shooter](https://kenney.nl/assets/top-down-shooter),
  licencia **CC0** (se pueden usar sin pedir permiso). La licencia original está
  en `assets/License.txt`. Les dejé los nombres de archivo originales por si hay
  que buscarlos en el pack.
- El código lo escribí yo para este trabajo práctico.
