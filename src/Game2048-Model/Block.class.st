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

{ #category : 'instance creation' }
Block class >> conValor: unNumero [
	^ self new valor: unNumero
]

{ #category : 'initialization' }
Block >> initialize [
	numero := 2.
	color := 'blanco'
]

{ #category : 'operation' }
Block >> valor [
	^ numero
]

{ #category : 'initialization' }
Block >> valor: unNumero [
	numero := unNumero
]

{ #category : 'operation' }
Block >> ver [
	^ { numero . color }
]
