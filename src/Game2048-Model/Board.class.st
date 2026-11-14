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
	board := {
		{0 . 0 . 0 . 0} .
		{0 . 0 . 0 . 0} .
		{0 . 0 . 0 . 0} .
		{0 . 0 . 0 . 0} 
	}
]

{ #category : 'operation' }
Board >> insertarBloque: unBloque posicion: tuplaPosicion [
	|x y|
	x := tuplaPosicion first. 
	y := tuplaPosicion last.
	((x >= 1) and: (x <= board size ))ifFalse: [  
		^ 'Error: posición X inválida.'	
	].
		
	((y >= 1) and: y <= ((board at: x) size)) ifFalse: [ 
		^ 'Error: posición Y inválida.'
	].

	(board at: x) at: y put: unBloque valor.
	
]

{ #category : 'operation' }
Board >> ver [
	^ board
]
