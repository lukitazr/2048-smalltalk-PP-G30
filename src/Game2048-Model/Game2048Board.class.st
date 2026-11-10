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
	board := #(
		#(0 0 0 0)
		#(0 0 0 0)
		#(0 0 0 0)
		#(0 0 0 0)
	)
]

{ #category : 'operation' }
Game2048Board >> ver [
	^ board
]
