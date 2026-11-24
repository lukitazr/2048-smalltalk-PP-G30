"
Please describe the package using the class comment of the included manifest class. The manifest class also includes other additional metadata for the package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : 'ManifestGame2048Model',
	#superclass : 'PackageManifest',
	#category : 'Game2048-Model-Manifest',
	#package : 'Game2048-Model',
	#tag : 'Manifest'
}

{ #category : 'code-critics' }
ManifestGame2048Model class >> ruleBadMessageRule2V1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGMethodDefinition #(#GUI #areaFlecha: #false)) #'2026-11-23T23:37:16.147-03:00') )
]
