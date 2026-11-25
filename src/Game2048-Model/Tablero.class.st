"
Representa la grilla cuadrada del 2048 como una matriz de números. El cero indica una casilla vacía. El tamaño permitido va de 3 a 10 y el predeterminado es 4.
"
Class {
	#name : 'Tablero',
	#superclass : 'Object',
	#instVars : [
		'board'
	],
	#category : 'Game2048-Model',
	#package : 'Game2048-Model'
}

{ #category : 'instance creation' }
Tablero class >> tamanio: unTamanio [
	"Crea un tablero cuadrado vacío del tamaño indicado. Señala BoardSizeError si el tamaño es inválido."

	^ self new
		inicializarConTamanio: unTamanio;
		yourself
]

{ #category : 'limits' }
Tablero class >> tamanioMaximo [
	"Devuelve la cantidad máxima permitida de filas y columnas."

	^ 10
]

{ #category : 'limits' }
Tablero class >> tamanioMinimo [
	"Devuelve la cantidad mínima permitida de filas y columnas."

	^ 3
]

{ #category : 'limits' }
Tablero class >> tamanioPorDefecto [
	"Devuelve la cantidad de filas y columnas que se usa al crear un tablero sin indicar el tamaño."

	^ 4
]

{ #category : 'initialization' }
Tablero >> inicializarConTamanio: unTamanio [
	"Valida el tamaño y crea una matriz con una colección independiente de ceros por fila. Señala BoardSizeError ante un tamaño inválido y conserva la matriz anterior."

	(unTamanio isInteger and: [ unTamanio between: self class tamanioMinimo and: self class tamanioMaximo ])
		ifFalse: [
			^ BoardSizeError signal: 'El tamaño del tablero debe ser un entero entre ', self class tamanioMinimo printString, ' y ', self class tamanioMaximo printString ].
	board := (1 to: unTamanio) collect: [ :fila | Array new: unTamanio withAll: 0 ]
]

{ #category : 'initialization' }
Tablero >> initialize [
	"Inicializa un tablero vacío con el tamaño predeterminado."

	super initialize.
	self inicializarConTamanio: self class tamanioPorDefecto
]

{ #category : 'accessing' }
Tablero >> posicionesVacias [
	"Devuelve las posiciones de las casillas con valor cero en orden de fila y columna. Cada posición tiene la forma fila @ columna."

	| vacias |
	vacias := OrderedCollection new.
	1 to: self size do: [ :fila |
		1 to: self size do: [ :columna |
			(self valorEn: fila @ columna) = 0 ifTrue: [ vacias add: fila @ columna ] ] ].
	^ vacias
]

{ #category : 'accessing' }
Tablero >> size [
	"Devuelve la cantidad de filas y columnas de la matriz cuadrada."

	^ board size
]

{ #category : 'accessing' }
Tablero >> valor: unNumero en: posicion [
	"Escribe el número en la casilla indicada por fila @ columna. Ambas coordenadas empiezan en 1."

	(board at: posicion x) at: posicion y put: unNumero
]

{ #category : 'accessing' }
Tablero >> valorEn: posicion [
	"Devuelve el número de la casilla indicada por fila @ columna, o cero si está vacía."

	^ (board at: posicion x) at: posicion y
]

{ #category : 'accessing' }
Tablero >> ver [
	"Devuelve una copia de la matriz y de cada fila para consultar el tablero sin modificar el original."

	^ board collect: [ :fila | fila copy ]
]
