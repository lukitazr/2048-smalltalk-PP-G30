Class {
	#name : 'GUI',
	#superclass : 'Morph',
	#instVars : [
		'reglas',
		'fuenteTitulo',
		'fuenteNormal',
		'fuenteFicha',
		'trayectorias',
		'inicioAnimacion',
		'direccionPendiente'
	],
	#category : 'Game2048-Model',
	#package : 'Game2048-Model'
}

{ #category : 'instance creation' }
GUI class >> abrir [
	| juego ventana |
	juego := self new.
	ventana := SystemWindow new.
	ventana setLabel: '2048 | G30'.
	ventana addMorph: juego frame: (0 @ 0 corner: 1 @ 1).
	ventana openInWorld.
	ventana extent: 420 @ 535.
	ventana beUnresizeable.
	ventana world activeHand newKeyboardFocus: juego.
	^ ventana
]

{ #category : 'drawing' }
GUI >> areaFichaFila: fila columna: columna [
	| desplazamiento |
	desplazamiento := (20 + ((columna - 1) * 90)) @ (92 + ((fila - 1) * 90)).
	^ (self bounds origin + desplazamiento) extent: 84 @ 84
]

{ #category : 'drawing' }
GUI >> areaReinicio [
	^ (self bounds origin + (258 @ 26)) extent: 116 @ 36
]

{ #category : 'drawing' }
GUI >> dibujar: texto centradoEn: rectangulo fuente: fuente color: colorTexto canvas: canvas [
	| ancho punto |
	ancho := fuente widthOfString: texto.
	punto := rectangulo center - ((ancho // 2) @ (fuente height // 2)).
	canvas drawString: texto at: punto font: fuente color: colorTexto
]

{ #category : 'drawing' }
GUI >> dibujarFicha: valor en: rectangulo canvas: canvas [
	| fondo |
	fondo := valor = 0
		ifTrue: [ Color r: 0.15 g: 0.21 b: 0.29 ]
		ifFalse: [ Color h: (223 + ((valor highBit - 2) * 27)) \\ 360 s: 0.68 v: 0.49 ].
	canvas fillRectangle: rectangulo color: fondo.
	valor = 0 ifTrue: [ ^ self ].
	self dibujar: valor asString centradoEn: rectangulo
		fuente: fuenteFicha color: Color white canvas: canvas
]

{ #category : 'event handling' }
GUI >> direccionParaTecla: tecla [
	tecla isArrowLeft ifTrue: [ ^ #izquierda ].
	tecla isArrowRight ifTrue: [ ^ #derecha ].
	tecla isArrowUp ifTrue: [ ^ #arriba ].
	tecla isArrowDown ifTrue: [ ^ #abajo ].
	^ nil
]

{ #category : 'drawing' }
GUI >> drawOn: canvas [
	| origen tablero estado |
	super drawOn: canvas.
	origen := self bounds origin.
	tablero := reglas board.
	canvas drawString: '2048' at: origen + (20 @ 12) font: fuenteTitulo color: Color white.
	canvas drawString: ('Puntaje: ', reglas puntaje asString)
		at: origen + (20 @ 60) font: fuenteNormal color: Color white.
	canvas fillRectangle: self areaReinicio color: (Color r: 0.20 g: 0.32 b: 0.48).
	self dibujar: 'Reiniciar (R)' centradoEn: self areaReinicio
		fuente: fuenteNormal color: Color white canvas: canvas.
	self dibujarTablero: tablero en: canvas.
	estado := 'Usá las flechas para mover las fichas.'.
	trayectorias ifNil: [
		reglas gano ifTrue: [ estado := 'Llegaste a 2048. Podés seguir jugando.' ].
		reglas termino ifTrue: [
			estado := reglas gano
				ifTrue: [ 'Llegaste a 2048. Partida terminada.' ]
				ifFalse: [ 'Sin movimientos. Reiniciá para volver a jugar.' ] ] ].
	canvas drawString: estado at: origen + (20 @ 458) font: fuenteNormal color: Color white
]

{ #category : 'event handling' }
GUI >> handlesKeyboard: evento [
	^ true
]

{ #category : 'event handling' }
GUI >> handlesMouseDown: evento [
	^ true
]

{ #category : 'initialization' }
GUI >> initialize [
	super initialize.
	reglas := Rules new.
	fuenteTitulo := LogicalFont familyName: 'Source Sans Pro' pointSize: 32.
	fuenteNormal := LogicalFont familyName: 'Source Sans Pro' pointSize: 14.
	fuenteFicha := LogicalFont familyName: 'Source Sans Pro' pointSize: 24.
	self color: (Color r: 0.08 g: 0.12 b: 0.17).
	self extent: 400 @ 500
]

{ #category : 'event handling' }
GUI >> keyDown: evento [
	| tecla direccion |
	tecla := evento key.
	direccion := self direccionParaTecla: tecla.
	direccion ifNil: [ ^ super keyDown: evento ].
	self mover: direccion.
	^ true
]

{ #category : 'event handling' }
GUI >> keyStroke: evento [
	| tecla |
	tecla := evento keyCharacter.
	(tecla = $r or: [ tecla = $R ]) ifTrue: [
		self reiniciar.
		^ true ].
	^ super keyStroke: evento
]

{ #category : 'event handling' }
GUI >> mouseDown: evento [
	evento hand newKeyboardFocus: self.
	(self areaReinicio containsPoint: evento position) ifTrue: [ self reiniciar ]
]

{ #category : 'operation' }
GUI >> reiniciar [
	trayectorias := nil.
	direccionPendiente := nil.
	self stopStepping.
	reglas reiniciar.
	self changed
]


{ #category : 'drawing' }
GUI >> dibujarTablero: tablero en: canvas [
	1 to: tablero size do: [ :fila |
		1 to: tablero size do: [ :columna |
			| valor |
			valor := trayectorias
				ifNil: [ tablero valorEn: fila @ columna ]
				ifNotNil: [ 0 ].
			self dibujarFicha: valor
				en: (self areaFichaFila: fila columna: columna) canvas: canvas ] ].
	trayectorias ifNotNil: [ self dibujarFichasEnMovimientoEn: canvas ]
]

{ #category : 'drawing' }
GUI >> dibujarFichasEnMovimientoEn: canvas [
	| avance |
	avance := ((Time millisecondsSince: inicioAnimacion) / self duracionAnimacion) min: 1.
	avance := 1 - (1 - avance) squared.
	trayectorias do: [ :trayectoria |
		| origen destino area areaDestino desplazamiento |
		origen := trayectoria second.
		destino := trayectoria third.
		area := self areaFichaFila: origen x columna: origen y.
		areaDestino := self areaFichaFila: destino x columna: destino y.
		desplazamiento := (areaDestino origin - area origin) * avance.
		self dibujarFicha: trayectoria first
			en: (area translateBy: desplazamiento rounded) canvas: canvas ]
]

{ #category : 'operation' }
GUI >> mover: direccion [
	| movimientos |
	trayectorias ifNotNil: [
		direccionPendiente := direccion.
		^ self ].
	movimientos := OrderedCollection new.
	(reglas mover: direccion registrando: [ :valor :origen :destino |
		movimientos add: { valor. origen. destino } ]) ifFalse: [ ^ self ].
	trayectorias := movimientos.
	inicioAnimacion := Time millisecondClockValue.
	self startStepping.
	self changed
]

{ #category : 'stepping' }
GUI >> duracionAnimacion [
	^ 120
]

{ #category : 'stepping' }
GUI >> stepTime [
	^ 16
]

{ #category : 'stepping' }
GUI >> step [
	| siguiente |
	trayectorias ifNil: [
		self stopStepping.
		^ self ].
	(Time millisecondsSince: inicioAnimacion) >= self duracionAnimacion ifTrue: [
		trayectorias := nil.
		self stopStepping.
		siguiente := direccionPendiente.
		direccionPendiente := nil.
		siguiente ifNotNil: [ self mover: siguiente ] ].
	self changed
]

{ #category : 'stepping' }
GUI >> wantsSteps [
	^ trayectorias notNil
]
