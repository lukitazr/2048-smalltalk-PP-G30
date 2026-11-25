"
Modelo de una partida de 2048. Aplica movimientos y fusiones, suma puntos, genera fichas y detecta la victoria y el fin de partida. Puede informar las trayectorias de las fichas para animarlas.
"
Class {
	#name : 'Reglas',
	#superclass : 'Object',
	#instVars : [
		'tablero',
		'puntaje',
		'gano',
		'azar'
	],
	#category : 'Game2048-Model',
	#package : 'Game2048-Model'
}

{ #category : 'instance creation' }
Reglas class >> tamanio: unTamanio [
	"Crea una partida del tamaño indicado con el puntaje en cero y dos fichas iniciales."

	^ self new
		tamanio: unTamanio;
		yourself
]

{ #category : 'private' }
Reglas >> agregarFicha [
	"Elige una casilla vacía al azar. Agrega un 4 con probabilidad del 10 % y un 2 en los demás casos. Si el tablero está lleno, no cambia."

	| vacias valor posicion |
	vacias := tablero posicionesVacias.
	vacias ifEmpty: [ ^ self ].
	valor := (azar nextInteger: 10) = 1 ifTrue: [ 4 ] ifFalse: [ 2 ].
	posicion := vacias at: (azar nextInteger: vacias size).
	tablero valor: valor en: posicion
]

{ #category : 'accessing' }
Reglas >> tablero [
	"Devuelve el tablero actual de la partida."

	^ tablero
]

{ #category : 'private' }
Reglas >> combinar: unaLinea [
	"Compacta y combina una línea ordenada desde el borde de destino. Cada ficha participa en una sola fusión. Devuelve la línea resultante, los puntos ganados y el índice de destino de cada ficha original. Las casillas originalmente vacías tienen destino nil."

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
Reglas >> gano [
	"Devuelve si la partida alcanzó la ficha 2048. El indicador se conserva hasta iniciar otra partida."

	^ gano
]

{ #category : 'initialization' }
Reglas >> initialize [
	"Prepara el generador aleatorio y comienza una partida del tamaño predeterminado."

	super initialize.
	azar := Random new.
	self reiniciar
]

{ #category : 'operation' }
Reglas >> mover: direccion [
	"Intenta mover las fichas en la dirección indicada. Devuelve si cambió el tablero."

	^ self mover: direccion registrando: nil
]

{ #category : 'operation' }
Reglas >> mover: direccion registrando: registrarFicha [
	"Aplica las fusiones y suma su valor al puntaje. Si recibe un bloque, le pasa el valor, el origen y el destino de cada ficha existente, incluso la que queda en su casilla. Solo agrega una ficha nueva cuando el tablero cambia y devuelve si hubo cambio."

	| cambio posiciones original resultado valores |
	(#(izquierda derecha arriba abajo) includes: direccion) ifFalse: [ ^ false ].
	cambio := false.
	1 to: tablero tamanio do: [ :indice |
		posiciones := self posicionesDeLinea: indice direccion: direccion.
		original := posiciones collect: [ :posicion | tablero valorEn: posicion ].
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
			1 to: tablero tamanio do: [ :i |
				tablero valor: (valores at: i) en: (posiciones at: i) ] ] ].
	cambio ifTrue: [ self agregarFicha ].
	^ cambio
]

{ #category : 'private' }
Reglas >> posicionesDeLinea: indice direccion: direccion [
	"Devuelve las posiciones de una fila o columna en orden desde el borde hacia el que se mueven las fichas. Cada posición tiene la forma fila @ columna."

	| indices |
	indices := (1 to: tablero tamanio) asArray.
	^ direccion caseOf: {
		[ #izquierda ] -> [ indices collect: [ :columna | indice @ columna ] ].
		[ #derecha ] -> [ indices reversed collect: [ :columna | indice @ columna ] ].
		[ #arriba ] -> [ indices collect: [ :fila | fila @ indice ] ].
		[ #abajo ] -> [ indices reversed collect: [ :fila | fila @ indice ] ] }
]

{ #category : 'accessing' }
Reglas >> puntaje [
	"Devuelve los puntos acumulados por las fusiones de la partida actual."

	^ puntaje
]

{ #category : 'operation' }
Reglas >> reiniciar [
	"Crea un tablero del mismo tamaño con dos fichas aleatorias y restablece el puntaje y el indicador de victoria. Usa el tamaño predeterminado en la primera partida."

	| tamanio |
	tamanio := tablero ifNil: [ Tablero tamanioPorDefecto ] ifNotNil: [ tablero tamanio ].
	tablero := Tablero tamanio: tamanio.
	puntaje := 0.
	gano := false.
	self agregarFicha.
	self agregarFicha
]

{ #category : 'accessing' }
Reglas >> tamanio [
	"Devuelve la cantidad de filas y columnas del tablero actual."

	^ tablero tamanio
]

{ #category : 'operation' }
Reglas >> tamanio: unTamanio [
	"Cambia el tamaño e inicia otra partida. Si el tamaño es inválido, señala ErrorTamanioTablero y conserva la partida actual."

	tablero := Tablero tamanio: unTamanio.
	self reiniciar
]

{ #category : 'testing' }
Reglas >> termino [
	"Devuelve si ya no hay ningún movimiento posible. Comprueba las cuatro direcciones sin modificar el tablero."

	^ (#(izquierda derecha arriba abajo) anySatisfy: [ :direccion |
		(1 to: tablero tamanio) anySatisfy: [ :indice |
			| original |
			original := (self posicionesDeLinea: indice direccion: direccion)
				collect: [ :posicion | tablero valorEn: posicion ].
			original ~= (self combinar: original) first ] ]) not
]
