"
Interfaz Morphic del 2048 con controles de teclado y mouse.
"
Class {
	#name : 'Interfaz',
	#superclass : 'Morph',
	#instVars : [
		'reglas',
		'fuenteTitulo',
		'fuenteNormal',
		'fuenteFicha',
		'trayectorias',
		'inicioAnimacion',
		'direccionPendiente',
		'direccionAnimada',
		'inicioAnimacionBoton',
		'escala',
		'escalaDeseada',
		'ventana'
	],
	#category : 'Game2048-Model',
	#package : 'Game2048-Model'
}

{ #category : 'instance creation' }
Interfaz class >> abrir [
	^ self abrirConTamanio: Tablero tamanioPorDefecto escala: 1
]

{ #category : 'instance creation' }
Interfaz class >> abrirConTamanio: unTamanio [
	^ self abrirConTamanio: unTamanio escala: 1
]

{ #category : 'instance creation' }
Interfaz class >> abrirConTamanio: unTamanio escala: unaEscala [
	| juego ventana |
	juego := self new.
	juego tamanio: unTamanio.
	juego escalaDeseada: unaEscala.
	ventana := SystemWindow new.
	ventana setLabel: '2048 | G30'.
	ventana addMorph: juego frame: (0 @ 0 corner: 1 @ 1).
	ventana openInWorld.
	juego ventana: ventana.
	juego reajustarVentana.
	ventana beUnresizeable.
	ventana world activeHand newKeyboardFocus: juego.
	^ ventana
]

{ #category : 'layout' }
Interfaz >> ajustarAPantalla: unaPantalla [
	self escala: (escalaDeseada min: (self escalaMaximaPara: unaPantalla))
]

{ #category : 'layout' }
Interfaz >> altoBase [
	^ 250 + (90 * self tamanio)
]

{ #category : 'layout' }
Interfaz >> anchoBase [
	^ (40 + (90 * self tamanio)) max: 400
]

{ #category : 'drawing' }
Interfaz >> areaFichaFila: fila columna: columna [
	| desplazamiento |
	desplazamiento := (self escalado: self margenTableroBase + ((columna - 1) * 90)) @ (self escalado: 92 + ((fila - 1) * 90)).
	^ (self bounds origin + desplazamiento) extent: (self escalado: 84) @ (self escalado: 84)
]

{ #category : 'drawing' }
Interfaz >> areaFlecha: direccion [
	| centroX yBase desplazamiento |
	centroX := self anchoBase // 2.
	yBase := 92 + (90 * self tamanio) + 60.
	desplazamiento := direccion caseOf: {
		[ #arriba ] -> [ (centroX - 21) @ (yBase - 48) ].
		[ #izquierda ] -> [ (centroX - 69) @ yBase ].
		[ #abajo ] -> [ (centroX - 21) @ yBase ].
		[ #derecha ] -> [ (centroX + 27) @ yBase ] }.
	^ (self bounds origin + (self escalado: desplazamiento)) extent: (self escalado: 46) @ (self escalado: 46)
]

{ #category : 'drawing' }
Interfaz >> areaReinicio [
	^ (self bounds origin + ((self escalado: self anchoBase - 142) @ (self escalado: 26))) extent: (self escalado: 116) @ (self escalado: 36)
]

{ #category : 'drawing' }
Interfaz >> areaTamanio [
	^ (self bounds origin + (self escalado: 144 @ 26)) extent: (self escalado: 104) @ (self escalado: 36)
]

{ #category : 'operation' }
Interfaz >> cambiarTamanioA: unTamanio [
	[ reglas tamanio: unTamanio ]
		on: ErrorTamanioTablero
		do: [ :error | ^ self ].
	trayectorias := nil.
	direccionPendiente := nil.
	direccionAnimada := nil.
	self stopStepping.
	self reajustarVentana.
	self changed
]

{ #category : 'drawing' }
Interfaz >> dibujar: texto centradoEn: rectangulo fuente: fuente color: colorTexto lienzo: lienzo [
	| ancho punto |
	ancho := fuente widthOfString: texto.
	punto := rectangulo center - ((ancho // 2) @ (fuente height // 2)).
	lienzo drawString: texto at: punto font: fuente color: colorTexto
]

{ #category : 'drawing' }
Interfaz >> dibujarFicha: valor en: rectangulo lienzo: lienzo [
	| fondo |
	fondo := valor = 0
		ifTrue: [ Color r: 0.15 g: 0.21 b: 0.29 ]
		ifFalse: [ Color h: (223 + ((valor highBit - 2) * 27)) \\ 360 s: 0.68 v: 0.49 ].
	lienzo fillRectangle: rectangulo color: fondo.
	valor = 0 ifTrue: [ ^ self ].
	self dibujar: valor asString centradoEn: rectangulo fuente: fuenteFicha color: Color white lienzo: lienzo
]

{ #category : 'drawing' }
Interfaz >> dibujarFichasEnMovimientoEn: lienzo [
	| avance |
	avance := ((Time millisecondClockValue - inicioAnimacion) / self duracionAnimacion) min: 1.
	avance := 1 - (1 - avance) squared.
	trayectorias do: [ :trayectoria |
		| origen destino area areaDestino desplazamiento |
		origen := trayectoria second.
		destino := trayectoria third.
		area := self areaFichaFila: origen x columna: origen y.
		areaDestino := self areaFichaFila: destino x columna: destino y.
		desplazamiento := (areaDestino origin - area origin) * avance.
		self dibujarFicha: trayectoria first en: (area translateBy: desplazamiento rounded) lienzo: lienzo ]
]

{ #category : 'drawing' }
Interfaz >> dibujarFlechasEn: lienzo [
	#(#arriba #izquierda #abajo #derecha) do: [ :direccion |
		| area activo color simbolo |
		area := self areaFlecha: direccion.
		activo := direccionAnimada = direccion and: [
			inicioAnimacionBoton notNil and: [ (Time millisecondClockValue - inicioAnimacionBoton) < self duracionAnimacionBoton ] ].
		color := activo
			ifTrue: [ Color r: 0.30 g: 0.62 b: 0.88 ]
			ifFalse: [ Color r: 0.20 g: 0.32 b: 0.48 ].
		lienzo fillRectangle: area color: color.
		simbolo := direccion caseOf: {
			[ #arriba ] -> [ '↑' ].
			[ #izquierda ] -> [ '←' ].
			[ #abajo ] -> [ '↓' ].
			[ #derecha ] -> [ '→' ] }.
		self dibujar: simbolo centradoEn: area fuente: fuenteNormal color: Color white lienzo: lienzo ]
]

{ #category : 'drawing' }
Interfaz >> dibujarTablero: tablero en: lienzo [
	1 to: tablero tamanio do: [ :fila |
		1 to: tablero tamanio do: [ :columna |
			| valor |
			valor := trayectorias
				ifNil: [ tablero valorEn: fila @ columna ]
				ifNotNil: [ 0 ].
			self dibujarFicha: valor en: (self areaFichaFila: fila columna: columna) lienzo: lienzo ] ].
	trayectorias ifNotNil: [ self dibujarFichasEnMovimientoEn: lienzo ]
]

{ #category : 'event handling' }
Interfaz >> direccionParaTecla: tecla [
	tecla isArrowLeft ifTrue: [ ^ #izquierda ].
	tecla isArrowRight ifTrue: [ ^ #derecha ].
	tecla isArrowUp ifTrue: [ ^ #arriba ].
	tecla isArrowDown ifTrue: [ ^ #abajo ].
	^ nil
]

{ #category : 'drawing' }
Interfaz >> drawOn: lienzo [
	| origen tablero estado |
	super drawOn: lienzo.
	origen := self bounds origin.
	tablero := reglas tablero.
	lienzo drawString: '2048' at: origen + ((self escalado: 20) @ (self escalado: 12)) font: fuenteTitulo color: Color white.
	lienzo drawString: ('Puntaje: ', reglas puntaje asString, '   Tablero: ', self tamanio asString, 'x', self tamanio asString)
		at: origen + ((self escalado: 20) @ (self escalado: 60)) font: fuenteNormal color: Color white.
	lienzo fillRectangle: self areaTamanio color: (Color r: 0.20 g: 0.32 b: 0.48).
	self dibujar: 'Tamaño (T)' centradoEn: self areaTamanio fuente: fuenteNormal color: Color white lienzo: lienzo.
	lienzo fillRectangle: self areaReinicio color: (Color r: 0.20 g: 0.32 b: 0.48).
	self dibujar: 'Reiniciar (R)' centradoEn: self areaReinicio fuente: fuenteNormal color: Color white lienzo: lienzo.
	self dibujarTablero: tablero en: lienzo.
	self dibujarFlechasEn: lienzo.
	estado := 'Usá las flechas o los botones para mover'.
	trayectorias ifNil: [
		reglas gano ifTrue: [ estado := 'Llegaste a 2048. Podés seguir jugando.' ].
		reglas termino ifTrue: [ estado := reglas gano
			ifTrue: [ 'Llegaste a 2048. Partida terminada.' ]
			ifFalse: [ 'Sin movimientos. Reiniciá para volver a jugar.' ] ] ].
	lienzo drawString: estado at: origen + ((self escalado: 20) @ (self escalado: self pieBase)) font: fuenteNormal color: Color white
]

{ #category : 'stepping' }
Interfaz >> duracionAnimacion [
	^ 120
]

{ #category : 'stepping' }
Interfaz >> duracionAnimacionBoton [
	^ 180
]

{ #category : 'operation' }
Interfaz >> elegirTamanio [
	| menu |
	menu := MenuMorph new.
	Tablero tamanioMinimo to: Tablero tamanioMaximo do: [ :tamanio |
		menu add: tamanio asString, ' x ', tamanio asString target: self selector: #cambiarTamanioA: argument: tamanio ].
	menu popUpInWorld
]

{ #category : 'accessing' }
Interfaz >> escala [
	^ escala
]

{ #category : 'layout' }
Interfaz >> escala: unNumero [
	escala := unNumero.
	fuenteTitulo := LogicalFont familyName: 'Source Sans Pro' pointSize: ((self escalado: 32) max: 6).
	fuenteNormal := LogicalFont familyName: 'Source Sans Pro' pointSize: ((self escalado: 14) max: 6).
	fuenteFicha := LogicalFont familyName: 'Source Sans Pro' pointSize: ((self escalado: 24) max: 6).
	self extent: (self escalado: self anchoBase) @ (self escalado: self altoBase)
]

{ #category : 'accessing' }
Interfaz >> escalaDeseada: unNumero [
	escalaDeseada := unNumero max: 0.2
]

{ #category : 'layout' }
Interfaz >> escalaMaximaPara: unaPantalla [
	| ancho alto |
	ancho := (unaPantalla x - 60) / self anchoBase.
	alto := (unaPantalla y - 75) / self altoBase.
	^ (ancho min: alto) asFloat max: 0.2
]

{ #category : 'layout' }
Interfaz >> escalado: unNumero [
	^ (unNumero * escala) rounded
]

{ #category : 'layout' }
Interfaz >> dimensionesVentana [
	^ ((self escalado: self anchoBase) + 20) @ ((self escalado: self altoBase) + 35)
]

{ #category : 'event handling' }
Interfaz >> handlesKeyboard: evento [
	^ true
]

{ #category : 'event handling' }
Interfaz >> handlesMouseDown: evento [
	^ true
]

{ #category : 'initialization' }
Interfaz >> initialize [
	super initialize.
	reglas := Reglas new.
	escalaDeseada := 1.
	self color: (Color r: 0.08 g: 0.12 b: 0.17).
	self escala: 1
]

{ #category : 'event handling' }
Interfaz >> keyDown: evento [
	| direccion |
	direccion := self direccionParaTecla: evento key.
	direccion ifNil: [ ^ super keyDown: evento ].
	self mover: direccion.
	^ true
]

{ #category : 'event handling' }
Interfaz >> keyStroke: evento [
	| tecla |
	tecla := evento keyCharacter.
	(tecla = $r or: [ tecla = $R ]) ifTrue: [ self reiniciar. ^ true ].
	(tecla = $t or: [ tecla = $T ]) ifTrue: [ self elegirTamanio. ^ true ].
	tecla = $+ ifTrue: [ self cambiarTamanioA: self tamanio + 1. ^ true ].
	tecla = $- ifTrue: [ self cambiarTamanioA: self tamanio - 1. ^ true ].
	^ super keyStroke: evento
]

{ #category : 'layout' }
Interfaz >> margenTableroBase [
	^ (self anchoBase - (90 * self tamanio)) // 2
]

{ #category : 'event handling' }
Interfaz >> mouseDown: evento [
	| posicion |
	posicion := evento position.
	evento hand newKeyboardFocus: self.
	(self areaReinicio containsPoint: posicion) ifTrue: [ ^ self reiniciar ].
	(self areaTamanio containsPoint: posicion) ifTrue: [ ^ self elegirTamanio ].
	#(#arriba #izquierda #abajo #derecha) do: [ :direccion |
		((self areaFlecha: direccion) containsPoint: posicion) ifTrue: [ ^ self mover: direccion ] ].
	^ super mouseDown: evento
]

{ #category : 'operation' }
Interfaz >> mover: direccion [
	| movimientos |
	direccionAnimada := direccion.
	inicioAnimacionBoton := Time millisecondClockValue.
	self startStepping.
	self changed.
	trayectorias ifNotNil: [ direccionPendiente := direccion. ^ self ].
	movimientos := OrderedCollection new.
	(reglas mover: direccion registrando: [ :valor :origen :destino | movimientos add: { valor. origen. destino } ]) ifFalse: [ ^ self ].
	trayectorias := movimientos.
	inicioAnimacion := Time millisecondClockValue.
	self startStepping.
	self changed
]

{ #category : 'layout' }
Interfaz >> pieBase [
	^ 218 + (90 * self tamanio)
]

{ #category : 'layout' }
Interfaz >> reajustarVentana [
	| mundo |
	mundo := self world ifNil: [ ^ self escala: escalaDeseada ].
	self ajustarAPantalla: mundo extent.
	ventana ifNotNil: [
		ventana extent: self dimensionesVentana.
		ventana position: ((mundo extent - ventana extent // 2) max: 0 @ 0) ]
]

{ #category : 'operation' }
Interfaz >> reiniciar [
	trayectorias := nil.
	direccionPendiente := nil.
	direccionAnimada := nil.
	self stopStepping.
	reglas reiniciar.
	self changed
]

{ #category : 'stepping' }
Interfaz >> step [
	| siguiente |
	trayectorias ifNotNil: [
		(Time millisecondClockValue - inicioAnimacion) >= self duracionAnimacion ifTrue: [
			trayectorias := nil.
			siguiente := direccionPendiente.
			direccionPendiente := nil.
			siguiente ifNotNil: [ self mover: siguiente ] ] ].
	direccionAnimada ifNotNil: [
		(Time millisecondClockValue - inicioAnimacionBoton) >= self duracionAnimacionBoton ifTrue: [ direccionAnimada := nil ] ].
	(trayectorias isNil and: [ direccionAnimada isNil ]) ifTrue: [ self stopStepping ].
	self changed
]

{ #category : 'stepping' }
Interfaz >> stepTime [
	^ 16
]

{ #category : 'accessing' }
Interfaz >> tamanio [
	^ reglas tamanio
]

{ #category : 'accessing' }
Interfaz >> tamanio: unTamanio [
	reglas tamanio: unTamanio
]

{ #category : 'accessing' }
Interfaz >> ventana: unaVentana [
	ventana := unaVentana
]

{ #category : 'stepping' }
Interfaz >> wantsSteps [
	^ trayectorias notNil or: [ direccionAnimada notNil ]
]
