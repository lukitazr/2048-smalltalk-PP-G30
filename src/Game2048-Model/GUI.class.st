{ #category : 'drawing' }
GUI >> areaFlecha: direccion [
	| centroX yBase desplazamiento |
	centroX := self anchoBase // 2.
	"Ubica los controles exactamente debajo del último cuadrado del tablero"
	yBase := 92 + (90 * self tamanio) + 14.
	desplazamiento := direccion = #arriba
		ifTrue: [ (centroX - 21) @ (yBase - 48) ]
		ifFalse: [ direccion = #izquierda
			ifTrue: [ (centroX - 69) @ yBase ]
			ifFalse: [ direccion = #abajo
				ifTrue: [ (centroX - 21) @ yBase ]
				ifFalse: [ (centroX + 27) @ yBase ] ] ].
	^ (self bounds origin + (self escalado: desplazamiento)) extent: (self escalado: 42) @ (self escalado: 42)
]

{ #category : 'drawing' }
GUI >> dibujarFlechasEn: canvas [
	#(#arriba #izquierda #abajo #derecha) do: [ :direccion |
		| area activo color simbolo |
		area := self areaFlecha: direccion.
		activo := direccionAnimada = direccion and: [
			(inicioAnimacionBoton isNotNil and: [
				(Time millisecondsSince: inicioAnimacionBoton) < self duracionAnimacionBoton ]) ].
		color := activo
			ifTrue: [ Color r: 0.30 g: 0.62 b: 0.88 ]
			ifFalse: [ Color r: 0.20 g: 0.32 b: 0.48 ].
		canvas fillRectangle: area color: color.
		simbolo := direccion = #arriba
			ifTrue: [ '↑' ]
			ifFalse: [ direccion = #izquierda
				ifTrue: [ '←' ]
				ifFalse: [ direccion = #abajo
					ifTrue: [ '↓' ]
					ifFalse: [ '→' ] ] ].
		self dibujar: simbolo centradoEn: area fuente: fuenteNormal color: Color white canvas: canvas ]
]

{ #category : 'event handling' }
GUI >> mouseDown: evento [
	| posicion |
	posicion := evento position.
	evento hand newKeyboardFocus: self.
	(self areaReinicio containsPoint: posicion) ifTrue: [ ^ self reiniciar ].
	(self areaTamanio containsPoint: posicion) ifTrue: [ ^ self elegirTamanio ].
	#(#arriba #izquierda #abajo #derecha) do: [ :direccion |
		(self areaFlecha: direccion) containsPoint: posicion
			ifTrue: [ ^ self mover: direccion ] ].
	^ super mouseDown: evento
]
