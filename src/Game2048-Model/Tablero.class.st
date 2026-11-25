"
Tablero cuadrado del 2048. Guarda el valor de cada casilla (0 = vacia). Su tamano es configurable entre tamanioMinimo y tamanioMaximo (por defecto 4); un tamano invalido lanza ErrorTamanioTablero.
"
Class {
	#name : 'Tablero',
	#superclass : 'Object',
	#instVars : [
		'matriz'
	],
	#category : 'Game2048-Model',
	#package : 'Game2048-Model'
}

{ #category : 'instance creation' }
Tablero class >> tamanio: unTamanio [
	"Crea un tablero vacio de unTamanio x unTamanio. Lanza ErrorTamanioTablero si esta fuera de los limites"

	^ self new
		inicializarConTamanio: unTamanio;
		yourself
]

{ #category : 'limits' }
Tablero class >> tamanioMaximo [
	"Mayor tamano de tablero permitido"

	^ 10
]

{ #category : 'limits' }
Tablero class >> tamanioMinimo [
	"Menor tamano de tablero permitido"

	^ 3
]

{ #category : 'limits' }
Tablero class >> tamanioPorDefecto [
	^ 4
]

{ #category : 'initialization' }
Tablero >> inicializarConTamanio: unTamanio [
	"Deja el tablero vacio con unTamanio filas y columnas. Si el tamano esta fuera de los limites no modifica nada y lanza ErrorTamanioTablero"

	(unTamanio isInteger and: [ unTamanio between: self class tamanioMinimo and: self class tamanioMaximo ])
		ifFalse: [
			^ ErrorTamanioTablero signal: 'El tamaño del tablero debe ser un entero entre ', self class tamanioMinimo printString, ' y ', self class tamanioMaximo printString ].
	matriz := (1 to: unTamanio) collect: [ :fila | Array new: unTamanio withAll: 0 ]
]

{ #category : 'initialization' }
Tablero >> initialize [
	super initialize.
	self inicializarConTamanio: self class tamanioPorDefecto
]

{ #category : 'accessing' }
Tablero >> posicionesVacias [
	| vacias |
	vacias := OrderedCollection new.
	1 to: self tamanio do: [ :fila |
		1 to: self tamanio do: [ :columna |
			(self valorEn: fila @ columna) = 0 ifTrue: [ vacias add: fila @ columna ] ] ].
	^ vacias
]

{ #category : 'accessing' }
Tablero >> tamanio [
	^ matriz size
]

{ #category : 'accessing' }
Tablero >> valor: unNumero en: posicion [
	(matriz at: posicion x) at: posicion y put: unNumero
]

{ #category : 'accessing' }
Tablero >> valorEn: posicion [
	^ (matriz at: posicion x) at: posicion y
]

{ #category : 'accessing' }
Tablero >> ver [
	^ matriz collect: [ :fila | fila copy ]
]
