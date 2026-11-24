"
Tablero cuadrado del 2048. Guarda el valor de cada casilla (0 = vacia). Su tamano es configurable entre tamanioMinimo y tamanioMaximo (por defecto 4); un tamano invalido lanza BoardSizeError.
"
Class {
	#name : 'Board',
	#superclass : 'Object',
	#instVars : [
		'board'
	],
	#category : 'Game2048-Model',
	#package : 'Game2048-Model'
}

{ #category : 'instance creation' }
Board class >> tamanio: unTamanio [
	"Crea un tablero vacio de unTamanio x unTamanio. Lanza BoardSizeError si esta fuera de los limites"

	^ self new
		inicializarConTamanio: unTamanio;
		yourself
]

{ #category : 'limits' }
Board class >> tamanioMaximo [
	"Mayor tamano de tablero permitido"

	^ 8
]

{ #category : 'limits' }
Board class >> tamanioMinimo [
	"Menor tamano de tablero permitido"

	^ 3
]

{ #category : 'limits' }
Board class >> tamanioPorDefecto [
	^ 4
]

{ #category : 'initialization' }
Board >> inicializarConTamanio: unTamanio [
	"Deja el tablero vacio con unTamanio filas y columnas. Si el tamano esta fuera de los limites no modifica nada y lanza BoardSizeError"

	(unTamanio isInteger and: [ unTamanio between: self class tamanioMinimo and: self class tamanioMaximo ])
		ifFalse: [
			^ BoardSizeError signal: 'El tamaño del tablero debe ser un entero entre ', self class tamanioMinimo printString, ' y ', self class tamanioMaximo printString ].
	board := (1 to: unTamanio) collect: [ :fila | Array new: unTamanio withAll: 0 ]
]

{ #category : 'initialization' }
Board >> initialize [
	super initialize.
	self inicializarConTamanio: self class tamanioPorDefecto
]

{ #category : 'operation' }
Board >> insertarBloque: unBloque posicion: tuplaPosicion [
	| fila columna posicion |
	
	"Extraemos la coordenada X de la tuplaPosicion"
	fila := tuplaPosicion first.
	(fila between: 1 and: self size) ifFalse: [ ^ 'Error: posición X inválida.' ].
	
	"Extraemos la coordenada Y de tupla posicion"
	columna := tuplaPosicion last.
	(columna between: 1 and: self size) ifFalse: [ ^ 'Error: posición Y inválida.' ].
	
	"Creamos una coordenada con x @ y"
	posicion := fila @ columna.
	
	(self valorEn: posicion) = 0 ifFalse: [ ^ 'Error: posición ocupada.' ].
	
	"Insertamos el bloque en la posición valida"
	self valor: unBloque valor en: posicion
]

{ #category : 'accessing' }
Board >> posicionesVacias [
	| vacias |
	vacias := OrderedCollection new.
	1 to: self size do: [ :fila |
		1 to: self size do: [ :columna |
			(self valorEn: fila @ columna) = 0 ifTrue: [ vacias add: fila @ columna ] ] ].
	^ vacias
]

{ #category : 'accessing' }
Board >> size [
	^ board size
]

{ #category : 'accessing' }
Board >> valor: unNumero en: posicion [
	(board at: posicion x) at: posicion y put: unNumero
]

{ #category : 'accessing' }
Board >> valorEn: posicion [
	^ (board at: posicion x) at: posicion y
]

{ #category : 'accessing' }
Board >> ver [
	^ board collect: [ :fila | fila copy ]
]
