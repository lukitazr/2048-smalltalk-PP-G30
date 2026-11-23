Class {
	#name : 'Board',
	#superclass : 'Object',
	#instVars : [
		'board'
	],
	#category : 'Game2048-Model',
	#package : 'Game2048-Model'
}

{ #category : 'initialization' }
Board >> initialize [
	super initialize.
	board := (1 to: 4) collect: [ :fila | Array new: 4 withAll: 0 ]
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
