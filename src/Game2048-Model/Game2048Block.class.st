Class {
	#name : 'Game2048Block',
	#superclass : 'Object',
	#instVars : [
		'numero',
		'color'
	],
	#category : 'Game2048-Model',
	#package : 'Game2048-Model'
}

{ #category : 'initialization' }
Game2048Block >> initialize [
	numero := 2.
	color := 'blanco'
]

{ #category : 'operation' }
Game2048Block >> ver [
	^ { numero . color }
]
