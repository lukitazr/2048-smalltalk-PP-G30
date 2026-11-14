Class {
	#name : 'Game2048Board',
	#superclass : 'Object',
	#instVars : [
		'board'
	],
	#category : 'Game2048-Model',
	#package : 'Game2048-Model'
}

{ #category : 'initialization' }
Game2048Board >> initialize [
	board := {
		{0 . 0 . 0 . 0} .
		{0 . 0 . 0 . 0} .
		{0 . 0 . 0 . 0} .
		{0 . 0 . 0 . 0} 
	}
]

{ #category : 'operation' }
Game2048Board >> insertarBloque: unBloque posicion: tuplaPosicion [
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
Game2048Board >> ver [
	^ board
]
