Class {
	#name : 'Block',
	#superclass : 'Object',
	#instVars : [
		'numero',
		'color'
	],
	#category : 'Game2048-Model',
	#package : 'Game2048-Model'
}

{ #category : 'initialization' }
Block >> initialize [
	numero := 2.
	color := 'blanco'
]

{ #category : 'operation' }
Block >> valor [
	^ numero
]

{ #category : 'operation' }
Block >> ver [
	^ { numero . color }
]
