"
Reglas del 2048: mueve y fusiona fichas en las cuatro direcciones, lleva el puntaje, detecta la victoria (2048) y el fin de partida. Funciona con tableros de cualquier tamano valido de Board y lo conserva al reiniciar.
"
Class {
	#name : 'Rules',
	#superclass : 'Object',
	#instVars : [
		'board',
		'puntaje',
		'gano',
		'azar'
	],
	#category : 'Game2048-Model',
	#package : 'Game2048-Model'
}

{ #category : 'instance creation' }
Rules class >> tamanio: unTamanio [
	^ self new
		tamanio: unTamanio;
		yourself
]

{ #category : 'private' }
Rules >> agregarFicha [
	| vacias valor posicion |
	vacias := board posicionesVacias.
	vacias ifEmpty: [ ^ self ].
	valor := (azar nextInteger: 10) = 1 ifTrue: [ 4 ] ifFalse: [ 2 ].
	posicion := vacias at: (azar nextInteger: vacias size).
	board valor: valor en: posicion
]

{ #category : 'accessing' }
Rules >> board [
	^ board
]

{ #category : 'private' }
Rules >> combinar: unaLinea [
	| fichas resultado destinos lectura escritura puntos valor |
	fichas := (1 to: unaLinea size) select: [ :indice | (unaLinea at: indice) ~= 0 ].
	destinos := Array new: unaLinea size.
	resultado := Array new: unaLinea size withAll: 0.
	lectura := 1.
	escritura := 1.
	puntos := 0.
	[ lectura <= fichas size ] whileTrue: [
		valor := unaLinea at: (fichas at: lectura).
		destinos at: (fichas at: lectura) put: escritura.
		lectura := lectura + 1.
		(lectura <= fichas size and: [ (unaLinea at: (fichas at: lectura)) = valor ]) ifTrue: [
			valor := valor * 2.
			puntos := puntos + valor.
			destinos at: (fichas at: lectura) put: escritura.
			lectura := lectura + 1 ].
		resultado at: escritura put: valor.
		escritura := escritura + 1 ].
	^ { resultado. puntos. destinos }
]

{ #category : 'testing' }
Rules >> gano [
	^ gano
]

{ #category : 'initialization' }
Rules >> initialize [
	super initialize.
	azar := Random new.
	self reiniciar
]

{ #category : 'operation' }
Rules >> mover: direccion [
	^ self mover: direccion registrando: nil
]

{ #category : 'operation' }
Rules >> mover: direccion registrando: registrarFicha [
	| cambio posiciones original resultado valores |
	(#(izquierda derecha arriba abajo) includes: direccion) ifFalse: [ ^ false ].
	cambio := false.
	1 to: board size do: [ :indice |
		posiciones := self posicionesDeLinea: indice direccion: direccion.
		original := posiciones collect: [ :posicion | board valorEn: posicion ].
		resultado := self combinar: original.
		valores := resultado first.
		registrarFicha ifNotNil: [
			resultado third withIndexDo: [ :destino :origen |
				destino ifNotNil: [
					registrarFicha
						value: (original at: origen)
						value: (posiciones at: origen)
						value: (posiciones at: destino) ] ] ].
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

{ #category : 'accessing' }
Rules >> puntaje [
	^ puntaje
]

{ #category : 'operation' }
Rules >> reiniciar [
	| tamanio |
	tamanio := board ifNil: [ Board tamanioPorDefecto ] ifNotNil: [ board size ].
	board := Board tamanio: tamanio.
	puntaje := 0.
	gano := false.
	self agregarFicha.
	self agregarFicha
]

{ #category : 'accessing' }
Rules >> tamanio [
	"Cantidad de filas (y de columnas) del tablero actual"

	^ board size
]

{ #category : 'operation' }
Rules >> tamanio: unTamanio [
	"Cambia el tamano del tablero y empieza una partida nueva. Si el tamano es invalido lanza BoardSizeError y no modifica la partida en curso"

	board := Board tamanio: unTamanio.
	self reiniciar
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
