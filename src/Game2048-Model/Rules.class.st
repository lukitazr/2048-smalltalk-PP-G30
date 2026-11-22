Class {
	#name : 'Rules',
	#superclass : 'Object',
	#instVars : [ 'board', 'puntaje', 'gano', 'azar' ],
	#category : 'Game2048-Model',
	#package : 'Game2048-Model'
}

{ #category : 'initialization' }
Rules >> initialize [
	super initialize.
	azar := Random new.
	self reiniciar
]

{ #category : 'operation' }
Rules >> reiniciar [
	board := Board new.
	puntaje := 0.
	gano := false.
	self agregarFicha.
	self agregarFicha
]

{ #category : 'accessing' }
Rules >> board [
	^ board
]

{ #category : 'accessing' }
Rules >> puntaje [
	^ puntaje
]

{ #category : 'testing' }
Rules >> gano [
	^ gano
]

{ #category : 'testing' }
Rules >> termino [
	^ (#(izquierda derecha arriba abajo) anySatisfy: [ :direccion |
		(1 to: board size) anySatisfy: [ :indice |
			| original |
			original := (self posicionesDeLinea: indice direccion: direccion)
				collect: [ :posicion | board valorEn: posicion ].
			original ~= (self combinar: original) first ] ]) not
]

{ #category : 'operation' }
Rules >> mover: direccion [
	| cambio posiciones original resultado valores |
	(#(izquierda derecha arriba abajo) includes: direccion) ifFalse: [ ^ false ].
	cambio := false.
	1 to: board size do: [ :indice |
		posiciones := self posicionesDeLinea: indice direccion: direccion.
		original := posiciones collect: [ :posicion | board valorEn: posicion ].
		resultado := self combinar: original.
		valores := resultado first.
		valores ~= original ifTrue: [
			cambio := true.
			puntaje := puntaje + resultado second.
			(valores includes: 2048) ifTrue: [ gano := true ].
			1 to: board size do: [ :i |
				board valor: (valores at: i) en: (posiciones at: i) ] ] ].
	cambio ifTrue: [ self agregarFicha ].
	^ cambio
]

{ #category : 'private' }
Rules >> posicionesDeLinea: indice direccion: direccion [
	| indices |
	indices := (1 to: board size) asArray.
	^ direccion caseOf: {
		[ #izquierda ] -> [ indices collect: [ :columna | indice @ columna ] ].
		[ #derecha ] -> [ indices reversed collect: [ :columna | indice @ columna ] ].
		[ #arriba ] -> [ indices collect: [ :fila | fila @ indice ] ].
		[ #abajo ] -> [ indices reversed collect: [ :fila | fila @ indice ] ] }
]

{ #category : 'private' }
Rules >> combinar: unaLinea [
	| fichas resultado lectura escritura puntos valor |
	fichas := unaLinea reject: [ :cadaValor | cadaValor = 0 ].
	resultado := Array new: unaLinea size withAll: 0.
	lectura := 1.
	escritura := 1.
	puntos := 0.
	[ lectura <= fichas size ] whileTrue: [
		valor := fichas at: lectura.
		lectura := lectura + 1.
		(lectura <= fichas size and: [ (fichas at: lectura) = valor ]) ifTrue: [
			valor := valor * 2.
			puntos := puntos + valor.
			lectura := lectura + 1 ].
		resultado at: escritura put: valor.
		escritura := escritura + 1 ].
	^ { resultado. puntos }
]

{ #category : 'private' }
Rules >> agregarFicha [
	| vacias valor posicion |
	vacias := board posicionesVacias.
	vacias ifEmpty: [ ^ self ].
	valor := (azar nextInteger: 10) = 1 ifTrue: [ 4 ] ifFalse: [ 2 ].
	posicion := vacias at: (azar nextInteger: vacias size).
	board insertarBloque: (Block conValor: valor)
		posicion: { posicion x. posicion y }
]
