" 
Interfaz Morphic del 2048. Dibuja el tablero de Rules con medidas que escalan segun el tamano del tablero y la pantalla (la escala nunca hace que la ventana se pase de la pantalla). Teclas: flechas para mover, R para reiniciar y T para elegir tamano.
" 
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
GUI class >> abrir [
	^ self abrirConTamanio: Board tamanioPorDefecto escala: 1
]

{ #category : 'instance creation' }
GUI class >> abrirConEscala: unaEscala [
	^ self abrirConTamanio: Board tamanioPorDefecto escala: unaEscala
]

{ #category : 'instance creation' }
GUI class >> abrirConTamanio: unTamanio [
	^ self abrirConTamanio: unTamanio escala: 1
]

{ #category : 'instance creation' }
GUI class >> abrirConTamanio: unTamanio escala: unaEscala [
	"Abre el juego con un tablero de unTamanio x unTamanio. La escala se reduce si hace falta para que la ventana entre en la pantalla"

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
GUI >> ajustarAPantalla: unaPantalla [
	"Usa la escala deseada, reducida si hace falta para que la ventana entre en unaPantalla"

	self escala: (escalaDeseada min: (self escalaMaximaPara: unaPantalla))
]

{ #category : 'layout' }
GUI >> altoBase [
	"Incluye el control de flechas debajo del tablero"

	^ 250 + (90 * self tamanio)
]

{ #category : 'layout' }
GUI >> anchoBase [
	"Ancho del morph: crece con el tablero y nunca baja de 400"

	^ (40 + (90 * self tamanio)) max: 400
]

{ #category : 'drawing' }
GUI >> areaFlecha: direccion [
	| centroX yBase desplazamiento |
	centroX := self anchoBase // 2.
	yBase := 108 + (90 * self tamanio).
	desplazamiento := direccion caseOf: {
		[ #arriba ] -> [ (centroX - 21) @ (yBase - 48) ].
		[ #izquierda ] -> [ (centroX - 69) @ yBase ].
		[ #abajo ] -> [ (centroX - 21) @ yBase ].
		[ #derecha ] -> [ (centroX + 27) @ yBase ] }.
	^ (self bounds origin + (self escalado: desplazamiento)) extent: (self escalado: 42) @ (self escalado: 42)
]

{ #category : 'drawing' }
GUI >> areaFichaFila: fila columna: columna [
	| desplazamiento |
	desplazamiento := (self escalado: self margenTableroBase + ((columna - 1) * 90)) @ (self escalado: 92 + ((fila - 1) * 90)).
	^ (self bounds origin + desplazamiento) extent: (self escalado: 84) @ (self escalado: 84)
]

{ #category : 'drawing' }
GUI >> areaReinicio [
	^ (self bounds origin + ((self escalado: self anchoBase - 142) @ (self escalado: 26))) extent: (self escalado: 116) @ (self escalado: 36)
]

{ #category : 'drawing' }
GUI >> areaTamanio [
	^ (self bounds origin + (self escalado: 144 @ 26)) extent: (self escalado: 104) @ (self escalado: 36)
]

{ #category : 'operation' }
GUI >> cambiarTamanioA: unTamanio [
	"Cambia el tamano del tablero (empieza una partida nueva) y adapta la escala y la ventana. Si el tamano esta fuera de los limites no hace nada"

	[ reglas tamanio: unTamanio ]
		on: BoardSizeError
		do: [ :error | ^ self ].
	trayectorias := nil.
	direccionPendiente := nil.
	self stopStepping.
	self reajustarVentana.
	self changed
]

{ #category : 'drawing' }
GUI >> dibujar: texto centradoEn: rectangulo fuente: fuente color: colorTexto canvas: canvas [
	| ancho punto |
	ancho := fuente widthOfString: texto.
	punto := rectangulo center - ((ancho // 2) @ (fuente height // 2)).
	canvas drawString: texto at: punto font: fuente color: colorTexto
]

{ #category : 'drawing' }
GUI >> dibujarFlechasEn: canvas [
	#(#arriba #izquierda #abajo #derecha) do: [ :direccion |
		| area activo color simbolo |
		area := self areaFlecha: direccion.
		activo := direccionAnimada = direccion and: [
			(Time millisecondsSince: inicioAnimacionBoton) < self duracionAnimacionBoton ].
		color := activo
			ifTrue: [ Color r: 0.30 g: 0.62 b: 0.88 ]
			ifFalse: [ Color r: 0.20 g: 0.32 b: 0.48 ].
		canvas fillRectangle: area color: color.
		simbolo := direccion caseOf: {
			[ #arriba ] -> [ '↑' ].
			[ #izquierda ] -> [ '←' ].
			[ #abajo ] -> [ '↓' ].
			[ #derecha ] -> [ '→' ] }.
		self dibujar: simbolo centradoEn: area fuente: fuenteNormal color: Color white canvas: canvas ]
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

{ #category : 'operation' }
GUI >> elegirTamanio [
	| menu |
	menu := MenuMorph new.
	Board tamanioMinimo to: Board tamanioMaximo do: [ :tamanio |
		menu
			add: tamanio asString, ' x ', tamanio asString
			target: self
			selector: #cambiarTamanioA:
			argument: tamanio ].
	menu popUpInWorld
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
	canvas drawString: '2048' at: origen + ((self escalado: 20) @ (self escalado: 12)) font: fuenteTitulo color: Color white.
	canvas drawString: ('Puntaje: ', reglas puntaje asString, '   Tablero: ', self tamanio asString, 'x', self tamanio asString)
		at: origen + ((self escalado: 20) @ (self escalado: 60)) font: fuenteNormal color: Color white.
	canvas fillRectangle: self areaTamanio color: (Color r: 0.20 g: 0.32 b: 0.48).
	self dibujar: 'Tamaño (T)' centradoEn: self areaTamanio
		fuente: fuenteNormal color: Color white canvas: canvas.
	canvas fillRectangle: self areaReinicio color: (Color r: 0.20 g: 0.32 b: 0.48).
	self dibujar: 'Reiniciar (R)' centradoEn: self areaReinicio
		fuente: fuenteNormal color: Color white canvas: canvas.
	self dibujarTablero: tablero en: canvas.
	self dibujarFlechasEn: canvas.
	estado := 'Usá las flechas del teclado o los botones para mover'.
	trayectorias ifNil: [
		reglas gano ifTrue: [ estado := 'Llegaste a 2048. Podés seguir jugando.' ].
		reglas termino ifTrue: [
			estado := reglas gano
				ifTrue: [ 'Llegaste a 2048. Partida terminada.' ]
				ifFalse: [ 'Sin movimientos. Reiniciá para volver a jugar.' ] ] ].
	canvas drawString: estado at: origen + ((self escalado: 20) @ (self escalado: self pieBase)) font: fuenteNormal color: Color white
]

{ #category : 'stepping' }
GUI >> duracionAnimacion [
	^ 120
]

{ #category : 'stepping' }
GUI >> duracionAnimacionBoton [
	^ 180
]

{ #category : 'operation' }
GUI >> elegirTamanio [
	| menu |
	menu := MenuMorph new.
	Board tamanioMinimo to: Board tamanioMaximo do: [ :tamanio |
		menu
			add: tamanio asString, ' x ', tamanio asString
			target: self
			selector: #cambiarTamanioA:
			argument: tamanio ].
	menu popUpInWorld
]

{ #category : 'accessing' }
GUI >> escala [
	^ escala
]

{ #category : 'layout' }
GUI >> escala: unNumero [
	"Aplica la escala (1 = tamano original): ajusta las fuentes y el tamano del morph"

	escala := unNumero.
	fuenteTitulo := LogicalFont familyName: 'Source Sans Pro' pointSize: ((self escalado: 32) max: 6).
	fuenteNormal := LogicalFont familyName: 'Source Sans Pro' pointSize: ((self escalado: 14) max: 6).
	fuenteFicha := LogicalFont familyName: 'Source Sans Pro' pointSize: ((self escalado: 24) max: 6).
	self extent: (self escalado: self anchoBase) @ (self escalado: self altoBase)
]

{ #category : 'accessing' }
GUI >> escalaDeseada: unNumero [
	"Escala pedida por el jugador (1 = tamano original). La escala efectiva puede ser menor si no entra en la pantalla"

	escalaDeseada := unNumero max: 0.2
]

{ #category : 'layout' }
GUI >> escalaMaximaPara: unaPantalla [
	"Mayor escala con la que la ventana entra en unaPantalla, dejando 20 px de margen por lado"

	| ancho alto |
	ancho := (unaPantalla x - 60) / self anchoBase.
	alto := (unaPantalla y - 75) / self altoBase.
	^ (ancho min: alto) asFloat max: 0.2
]

{ #category : 'layout' }
GUI >> escalado: unNumero [
	"Convierte una medida en pixeles con escala 1 a la escala actual"

	^ (unNumero * escala) rounded
]

{ #category : 'layout' }
GUI >> extentVentana [
	"Tamano de la ventana que contiene al juego con la escala actual"

	^ ((self escalado: self anchoBase) + 20) @ ((self escalado: self altoBase) + 35)
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
	escalaDeseada := 1.
	self color: (Color r: 0.08 g: 0.12 b: 0.17).
	self escala: 1
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
	(tecla = $t or: [ tecla = $T ]) ifTrue: [
		self elegirTamanio.
		^ true ].
	tecla = $+ ifTrue: [
		self cambiarTamanioA: self tamanio + 1.
		^ true ].
	tecla = $- ifTrue: [
		self cambiarTamanioA: self tamanio - 1.
		^ true ].
	^ super keyStroke: evento
]

{ #category : 'layout' }
GUI >> margenTableroBase [
	"Margen izquierdo del tablero con escala 1: lo deja centrado"

	^ (self anchoBase - (90 * self tamanio)) // 2
]

{ #category : 'event handling' }
GUI >> mouseDown: evento [
	evento hand newKeyboardFocus: self.
	(self areaReinicio containsPoint: evento position) ifTrue: [ ^ self reiniciar ].
	(self areaTamanio containsPoint: evento position) ifTrue: [ ^ self elegirTamanio ].
	#(#arriba #izquierda #abajo #derecha) do: [ :direccion |
		(self areaFlecha: direccion) containsPoint: evento position ifTrue: [ ^ self mover: direccion ] ]
]

{ #category : 'operation' }
GUI >> mover: direccion [
	| movimientos |
	direccionAnimada := direccion.
	inicioAnimacionBoton := Time millisecondClockValue.
	self startStepping.
	self changed.
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

{ #category : 'layout' }
GUI >> pieBase [
	"Posicion vertical del texto de estado debajo de los botones de movimiento"

	^ 218 + (90 * self tamanio)
]

{ #category : 'layout' }
GUI >> reajustarVentana [
	"Adapta la escala y la ventana al tamano actual del tablero y a la pantalla, y centra la ventana"

	| mundo |
	mundo := self world ifNil: [ ^ self escala: escalaDeseada ].
	self ajustarAPantalla: mundo extent.
	ventana ifNotNil: [
		ventana extent: self extentVentana.
		ventana position: ((mundo extent - ventana extent // 2) max: 0 @ 0) ]
]

{ #category : 'operation' }
GUI >> reiniciar [
	trayectorias := nil.
	direccionPendiente := nil.
	self stopStepping.
	reglas reiniciar.
	self changed
]

{ #category : 'stepping' }
GUI >> step [
	| siguiente |
	trayectorias ifNotNil: [
		(Time millisecondsSince: inicioAnimacion) >= self duracionAnimacion ifTrue: [
			trayectorias := nil.
			siguiente := direccionPendiente.
			direccionPendiente := nil.
			siguiente ifNotNil: [ self mover: siguiente ] ] ].
		direccionAnimada ifNotNil: [
			(Time millisecondsSince: inicioAnimacionBoton) >= self duracionAnimacionBoton ifTrue: [ direccionAnimada := nil ] ].
		(trayectorias isNil and: [ direccionAnimada isNil ]) ifTrue: [ self stopStepping ].
	self changed
]

{ #category : 'stepping' }
GUI >> stepTime [
	^ 16
]

{ #category : 'accessing' }
GUI >> tamanio [
	"Cantidad de filas (y de columnas) del tablero"

	^ reglas tamanio
]

{ #category : 'accessing' }
GUI >> tamanio: unTamanio [
	"Cambia el tamano del tablero sin tocar la ventana. Lanza BoardSizeError si esta fuera de los limites"

	reglas tamanio: unTamanio
]

{ #category : 'accessing' }
GUI >> ventana: unaVentana [
	ventana := unaVentana
]

{ #category : 'stepping' }
GUI >> wantsSteps [
	^ trayectorias notNil or: [ direccionAnimada notNil ]
]
