# 2048 en Pharo

Implementación del juego 2048 en Smalltalk, desarrollada por el Grupo 30. La interfaz usa Morphic y permite jugar con el teclado o con los botones en pantalla. El tablero es de 4 × 4 por defecto y se puede configurar entre 3 × 3 y 10 × 10.

## Cómo cargar y ejecutar el juego

1. Abrí una imagen de **Pharo 14**.
2. Abrí **Iceberg** (Git Repositories Browser) y agregá el repositorio con la opción de clonar por HTTPS. Usá la URL `https://github.com/lukitazr/2048-smalltalk-PP-G30.git`.
3. En la rama `main`, abrí el repositorio en Iceberg y cargá el paquete `Game2048-Model`, ubicado en `src`.
4. Abrí un **Playground** y evaluá con **Do it**:

```smalltalk
GUI abrir
```

También podés abrir una partida con otro tamaño desde el Playground:

```smalltalk
GUI abrirConTamanio: 6
```

## Cómo jugar

La partida empieza con dos fichas. En cada movimiento, las fichas se deslizan hasta el borde elegido o hasta que otra ficha las bloquea. Dos fichas consecutivas del mismo valor se fusionan en una del doble de valor. Cada ficha participa en una sola fusión por movimiento y el valor resultante se suma al puntaje.

Si el tablero cambia, aparece una ficha nueva en una casilla vacía. El objetivo es llegar a **2048**. Podés seguir jugando después de alcanzarlo. La partida termina cuando ya no hay movimientos posibles.

| Acción | Control |
| --- | --- |
| Mover las fichas | Flechas del teclado o botones en pantalla |
| Reiniciar la partida | `R` o botón **Reiniciar** |
| Elegir el tamaño del tablero | `T` o botón **Tamaño** |
| Aumentar o reducir el tamaño en una casilla por lado | `+` o `-` |

Cambiar el tamaño inicia una partida nueva. Si el teclado no responde, hacé clic en el tablero para darle el foco a la ventana.

## Organización del código

El paquete [`Game2048-Model`](src/Game2048-Model) se guarda en formato Tonel.

| Clase | Responsabilidad |
| --- | --- |
| [`GUI`](src/Game2048-Model/GUI.class.st) | Dibuja el tablero y el puntaje, recibe los controles y anima el desplazamiento de las fichas. |
| [`Reglas`](src/Game2048-Model/Reglas.class.st) | Aplica los movimientos y las fusiones, actualiza el puntaje, agrega fichas y detecta la victoria y el fin de la partida. |
| [`Tablero`](src/Game2048-Model/Tablero.class.st) | Guarda la matriz de casillas, permite consultar y modificar sus valores y valida sus dimensiones. El cero representa una casilla vacía. |
| [`BoardSizeError`](src/Game2048-Model/BoardSizeError.class.st) | Identifica los tamaños de tablero inválidos. |

`Reglas` informa a `GUI` el origen y el destino de las fichas para que la interfaz pueda animarlas. El modelo se puede usar desde el Playground sin abrir una ventana.
