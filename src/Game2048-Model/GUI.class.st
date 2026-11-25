"
Interfaz Morphic del 2048. Dibuja el tablero y el puntaje, recibe controles de teclado y mouse y anima las trayectorias que informa Reglas. El juego se inicia con GUI abrir.
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
	"Abre el juego con el tamaño de tablero predeterminado y devuelve la ventana."

	^ self abrirConTamanio: Tablero tamanioPorDefecto escala: 1
]

{ #category : 'instance creation' }
GUI class >> abrirConTamanio: unTamanio [
	"Abre el juego con el tamaño indicado y una escala inicial de 1."

	^ self abrirConTamanio: unTamanio escala: 1
]

{ #category : 'instance creation' }
GUI class >> abrirConTamanio: unTamanio escala: unaEscala [
	"Crea la ventana de Morphic, ajusta su tamaño y entrega el foco del teclado al juego. Devuelve la ventana abierta."

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
	"Aplica la escala deseada hasta el máximo calculado para el área disponible."

	self escala: (escalaDeseada min: (self escalaMaximaPara: unaPantalla))
]

{ #category : 'layout' }
GUI >> altoBase [
	"Devuelve la altura sin escalar, incluidos el tablero, los controles y el pie."

	^ 250 + (90 * self tamanio)
]

{ #category : 'layout' }
GUI >> anchoBase [
	"Devuelve el ancho sin escalar, con un mínimo de 400 píxeles para los controles."

	^ (40 + (90 * self tamanio)) max: 400
]

{ #category : 'drawing' }
GUI >> areaFichaFila: fila columna: columna [
	"Devuelve el rectángulo de una casilla en coordenadas de Morphic. La fila y la columna empiezan en 1."

	| desplazamiento |
	desplazamiento := (self escalado: self margenTableroBase + ((columna - 1) * 90)) @ (self escalado: 92 + ((fila - 1) * 90)).
	^ (self bounds origin + desplazamiento) extent: (self escalado: 84) @ (self escalado: 84)
]

{ #category : 'drawing' }
GUI >> areaFlecha: direccion [
	"Devuelve el rectángulo del botón de la dirección indicada. Se usa tanto para dibujarlo como para detectar clics."

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
GUI >> areaReinicio [
	"Devuelve el rectángulo del botón de reinicio en coordenadas de Morphic."

	^ (self bounds origin + ((self escalado: self anchoBase - 142) @ (self escalado: 26))) extent: (self escalado: 116) @ (self escalado: 36)
]

{ #category : 'drawing' }
GUI >> areaTamanio [
	"Devuelve el rectángulo del botón que abre el menú de tamaños."

	^ (self bounds origin + (self escalado: 144 @ 26)) extent: (self escalado: 104) @ (self escalado: 36)
]

{ #category : 'operation' }
GUI >> cambiarTamanioA: unTamanio [
	"Cambia el tamaño y arranca otra partida. Si el tamaño es inválido, conserva la partida actual. Un cambio válido cancela las animaciones y reajusta la ventana."

	[ reglas tamanio: unTamanio ]
		on: BoardSizeError
		do: [ :error | ^ self ].
	trayectorias := nil.
	direccionPendiente := nil.
	direccionAnimada := nil.
	self stopStepping.
	self reajustarVentana.
	self changed
]

{ #category : 'drawing' }
GUI >> dibujar: texto centradoEn: rectangulo fuente: fuente color: colorTexto canvas: canvas [
	"Dibuja el texto centrado en el rectángulo con la fuente y el color indicados."

	| ancho punto |
	ancho := fuente widthOfString: texto.
	punto := rectangulo center - ((ancho // 2) @ (fuente height // 2)).
	canvas drawString: texto at: punto font: fuente color: colorTexto
]

{ #category : 'drawing' }
GUI >> dibujarFicha: valor en: rectangulo canvas: canvas [
	"Dibuja el fondo según el valor de la casilla. Para el valor cero, deja la casilla sin texto."

	| fondo |
	fondo := valor = 0
		ifTrue: [ Color r: 0.15 g: 0.21 b: 0.29 ]
		ifFalse: [ Color h: (223 + ((valor highBit - 2) * 27)) \\ 360 s: 0.68 v: 0.49 ].
	canvas fillRectangle: rectangulo color: fondo.
	valor = 0 ifTrue: [ ^ self ].
	self dibujar: valor asString centradoEn: rectangulo fuente: fuenteFicha color: Color white canvas: canvas
]

{ #category : 'drawing' }
GUI >> dibujarFichasEnMovimientoEn: canvas [
	"Dibuja las fichas entre sus casillas de origen y destino según el tiempo transcurrido. Reduce la velocidad al acercarse al destino."

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
		self dibujarFicha: trayectoria first en: (area translateBy: desplazamiento rounded) canvas: canvas ]
]

{ #category : 'drawing' }
GUI >> dibujarFlechasEn: canvas [
	"Dibuja los cuatro botones de dirección y resalta temporalmente el último que se activó."

	#(#arriba #izquierda #abajo #derecha) do: [ :direccion |
		| area activo color simbolo |
		area := self areaFlecha: direccion.
		activo := direccionAnimada = direccion and: [
			inicioAnimacionBoton notNil and: [ (Time millisecondClockValue - inicioAnimacionBoton) < self duracionAnimacionBoton ] ].
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
GUI >> dibujarTablero: tablero en: canvas [
	"Dibuja el tablero actual. Durante un deslizamiento, dibuja primero las casillas vacías y luego superpone las fichas en tránsito."

	1 to: tablero size do: [ :fila |
		1 to: tablero size do: [ :columna |
			| valor |
			valor := trayectorias
				ifNil: [ tablero valorEn: fila @ columna ]
				ifNotNil: [ 0 ].
			self dibujarFicha: valor en: (self areaFichaFila: fila columna: columna) canvas: canvas ] ].
	trayectorias ifNotNil: [ self dibujarFichasEnMovimientoEn: canvas ]
]

{ #category : 'event handling' }
GUI >> direccionParaTecla: tecla [
	"Convierte una tecla de flecha en una dirección de juego. Devuelve nil para las demás teclas."

	tecla isArrowLeft ifTrue: [ ^ #izquierda ].
	tecla isArrowRight ifTrue: [ ^ #derecha ].
	tecla isArrowUp ifTrue: [ ^ #arriba ].
	tecla isArrowDown ifTrue: [ ^ #abajo ].
	^ nil
]

{ #category : 'drawing' }
GUI >> drawOn: canvas [
	"Morphic invoca este método para pintar el fondo, el tablero, los controles, el puntaje y el estado de la partida."

	| origen tablero estado |
	super drawOn: canvas.
	origen := self bounds origin.
	tablero := reglas board.
	canvas drawString: '2048' at: origen + ((self escalado: 20) @ (self escalado: 12)) font: fuenteTitulo color: Color white.
	canvas drawString: ('Puntaje: ', reglas puntaje asString, '   Tablero: ', self tamanio asString, 'x', self tamanio asString)
		at: origen + ((self escalado: 20) @ (self escalado: 60)) font: fuenteNormal color: Color white.
	canvas fillRectangle: self areaTamanio color: (Color r: 0.20 g: 0.32 b: 0.48).
	self dibujar: 'Tamaño (T)' centradoEn: self areaTamanio fuente: fuenteNormal color: Color white canvas: canvas.
	canvas fillRectangle: self areaReinicio color: (Color r: 0.20 g: 0.32 b: 0.48).
	self dibujar: 'Reiniciar (R)' centradoEn: self areaReinicio fuente: fuenteNormal color: Color white canvas: canvas.
	self dibujarTablero: tablero en: canvas.
	self dibujarFlechasEn: canvas.
	estado := 'Usá las flechas o los botones para mover'.
	trayectorias ifNil: [
		reglas gano ifTrue: [ estado := 'Llegaste a 2048. Podés seguir jugando.' ].
		reglas termino ifTrue: [ estado := reglas gano
			ifTrue: [ 'Llegaste a 2048. Partida terminada.' ]
			ifFalse: [ 'Sin movimientos. Reiniciá para volver a jugar.' ] ] ].
	canvas drawString: estado at: origen + ((self escalado: 20) @ (self escalado: self pieBase)) font: fuenteNormal color: Color white
]

{ #category : 'stepping' }
GUI >> duracionAnimacion [
	"Devuelve la duración del desplazamiento de las fichas en milisegundos."

	^ 120
]

{ #category : 'stepping' }
GUI >> duracionAnimacionBoton [
	"Devuelve la duración del resaltado de un botón de dirección en milisegundos."

	^ 180
]

{ #category : 'operation' }
GUI >> elegirTamanio [
	"Abre un menú con los tamaños válidos. Elegir uno inicia una partida con ese tamaño."

	| menu |
	menu := MenuMorph new.
	Tablero tamanioMinimo to: Tablero tamanioMaximo do: [ :tamanio |
		menu add: tamanio asString, ' x ', tamanio asString target: self selector: #cambiarTamanioA: argument: tamanio ].
	menu popUpInWorld
]

{ #category : 'accessing' }
GUI >> escala [
	"Devuelve el factor de escala aplicado al dibujo."

	^ escala
]

{ #category : 'layout' }
GUI >> escala: unNumero [
	"Aplica el factor de escala a las dimensiones del Morph y al tamaño de las fuentes."

	escala := unNumero.
	fuenteTitulo := LogicalFont familyName: 'Source Sans Pro' pointSize: ((self escalado: 32) max: 6).
	fuenteNormal := LogicalFont familyName: 'Source Sans Pro' pointSize: ((self escalado: 14) max: 6).
	fuenteFicha := LogicalFont familyName: 'Source Sans Pro' pointSize: ((self escalado: 24) max: 6).
	self extent: (self escalado: self anchoBase) @ (self escalado: self altoBase)
]

{ #category : 'accessing' }
GUI >> escalaDeseada: unNumero [
	"Guarda la escala solicitada, con un mínimo de 0,2. El ajuste a pantalla determina la escala aplicada."

	escalaDeseada := unNumero max: 0.2
]

{ #category : 'layout' }
GUI >> escalaMaximaPara: unaPantalla [
	"Calcula el factor de escala según el ancho y el alto disponibles, con márgenes para la ventana y un mínimo de 0,2."

	| ancho alto |
	ancho := (unaPantalla x - 60) / self anchoBase.
	alto := (unaPantalla y - 75) / self altoBase.
	^ (ancho min: alto) asFloat max: 0.2
]

{ #category : 'layout' }
GUI >> escalado: unNumero [
	"Multiplica un número o punto por la escala actual y redondea el resultado."

	^ (unNumero * escala) rounded
]

{ #category : 'layout' }
GUI >> extentVentana [
	"Devuelve el ancho y el alto de la ventana, incluidos los márgenes que rodean el juego."

	^ ((self escalado: self anchoBase) + 20) @ ((self escalado: self altoBase) + 35)
]

{ #category : 'event handling' }
GUI >> handlesKeyboard: evento [
	"Indica a Morphic que este Morph acepta eventos de teclado."

	^ true
]

{ #category : 'event handling' }
GUI >> handlesMouseDown: evento [
	"Indica a Morphic que este Morph acepta eventos de pulsación del mouse."

	^ true
]

{ #category : 'initialization' }
GUI >> initialize [
	"Crea una partida y configura el color de fondo y la escala inicial del Morph."

	super initialize.
	reglas := Reglas new.
	escalaDeseada := 1.
	self color: (Color r: 0.08 g: 0.12 b: 0.17).
	self escala: 1
]

{ #category : 'event handling' }
GUI >> keyDown: evento [
	"Procesa las flechas al presionarlas. Delega al comportamiento heredado las demás teclas."

	| direccion |
	direccion := self direccionParaTecla: evento key.
	direccion ifNil: [ ^ super keyDown: evento ].
	self mover: direccion.
	^ true
]

{ #category : 'event handling' }
GUI >> keyStroke: evento [
	"Procesa los atajos R para reiniciar, T para elegir el tamaño y los signos más y menos para ajustarlo."

	| tecla |
	tecla := evento keyCharacter.
	(tecla = $r or: [ tecla = $R ]) ifTrue: [ self reiniciar. ^ true ].
	(tecla = $t or: [ tecla = $T ]) ifTrue: [ self elegirTamanio. ^ true ].
	tecla = $+ ifTrue: [ self cambiarTamanioA: self tamanio + 1. ^ true ].
	tecla = $- ifTrue: [ self cambiarTamanioA: self tamanio - 1. ^ true ].
	^ super keyStroke: evento
]

{ #category : 'layout' }
GUI >> margenTableroBase [
	"Calcula el margen izquierdo sin escalar para centrar la grilla."

	^ (self anchoBase - (90 * self tamanio)) // 2
]

{ #category : 'event handling' }
GUI >> mouseDown: evento [
	"Recupera el foco del teclado y ejecuta la acción del botón que recibió el clic."

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
GUI >> mover: direccion [
	"Resalta la dirección y pide a Reglas que aplique el movimiento. Si hay un deslizamiento en curso, conserva la última dirección solicitada para ejecutarla al terminar."

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
GUI >> pieBase [
	"Devuelve la coordenada vertical sin escalar del mensaje al pie de la ventana."

	^ 218 + (90 * self tamanio)
]

{ #category : 'layout' }
GUI >> reajustarVentana [
	"Ajusta la escala al espacio disponible y centra la ventana si ya está abierta."

	| mundo |
	mundo := self world ifNil: [ ^ self escala: escalaDeseada ].
	self ajustarAPantalla: mundo extent.
	ventana ifNotNil: [
		ventana extent: self extentVentana.
		ventana position: ((mundo extent - ventana extent // 2) max: 0 @ 0) ]
]

{ #category : 'operation' }
GUI >> reiniciar [
	"Cancela los efectos y la dirección pendiente e inicia otra partida del mismo tamaño."

	trayectorias := nil.
	direccionPendiente := nil.
	direccionAnimada := nil.
	self stopStepping.
	reglas reiniciar.
	self changed
]

{ #category : 'stepping' }
GUI >> step [
	"Actualiza las animaciones. Al terminar el deslizamiento, aplica la dirección pendiente si existe. Detiene las actualizaciones cuando ya no queda ningún efecto activo."

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
GUI >> stepTime [
	"Indica a Morphic el intervalo de actualización de las animaciones en milisegundos."

	^ 16
]

{ #category : 'accessing' }
GUI >> tamanio [
	"Devuelve la cantidad de filas y columnas del tablero actual."

	^ reglas tamanio
]

{ #category : 'accessing' }
GUI >> tamanio: unTamanio [
	"Inicia una partida del tamaño indicado en el modelo. La apertura de la ventana lo usa antes de calcular sus dimensiones."

	reglas tamanio: unTamanio
]

{ #category : 'accessing' }
GUI >> ventana: unaVentana [
	"Guarda la ventana de Morphic que contiene este Morph."

	ventana := unaVentana
]

{ #category : 'stepping' }
GUI >> wantsSteps [
	"Indica a Morphic si hay fichas en tránsito o un botón resaltado que necesite actualizarse."

	^ trayectorias notNil or: [ direccionAnimada notNil ]
]
