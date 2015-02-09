turtles-own [pegado]

to setup
  ca
  create-turtles cantidad-sir [setxy random-xcor random-ycor set color blue set shape "circle 2"];;crear sir2
  create-turtles cantidad-sas [setxy random-xcor random-ycor set color red set shape "triangle 2"];;crear sas2
  ask turtles [set pegado false]
end


to go
  tick
  if ticks > 50000 [stop]
  ;;move
  ask turtles with [pegado = false] [right random 360 forward 1]
  
  ;;despegado sas
  ask turtles with [shape = "triangle"] [
    if random-float 1 < despegado-sas [
      set shape "triangle 2"
      set pegado false
      forward 1]
    ]
  
  ;;despegado sir
  ask turtles with [(shape = "circle") and (pxcor != 0)] [
    let amigas (count turtles in-radius 1 with [shape = "circle"])  ;;cooperatividad
    if random-float 1 < despegado-sir * (1 - amigas * cooperatividad-sir)  [
      set shape "circle 2" 
      set pegado false
      forward 1]
    ]
  
  ;;pegado sas
  ask turtles with [(shape = "triangle 2") and (pcolor = cyan) and (pegado = false) and (count turtles-here = 1)] [
    let amigas (count turtles in-radius 1 with [shape = "triangle"])  ;;cooperatividad
    if random-float 1 < afinidad-sas + amigas * cooperatividad-sas [ ;;aleatorio
      setxy pxcor pycor
      set shape "triangle"
      set pegado true 
      set pcolor yellow]
    ]
 
  ;;pegado sir
  ask turtles with [(shape = "circle 2") and (pcolor = cyan) and (pegado = false) and (count turtles-here = 1)] [
    let amigas (count turtles in-radius 1 with [shape = "circle"])  ;;cooperatividad
    if random-float 1 < (afinidad-sir + amigas * cooperatividad-sir) [ ;;aleatorio
      setxy pxcor pycor
      set shape "circle"
      set pegado true ]
    ]
  
  ;;cambio estado DNA
  ask patches with [(pycor = 0) and (count turtles-here = 0)] [
    let csas count turtles in-radius 1 with [shape = "triangle"];;cantidad sas
    let csir count turtles in-radius 1 with [shape = "circle"];;cantidad sir
    ;;acetilacion
    if random-float 1 < acetilacion-sas * csas - deacetilacion-sir * csir
      [set pcolor yellow]
    ;;deacetilacion
    if random-float 1 < deacetilacion-sir * csir - acetilacion-sas * csas
      [set pcolor cyan]
  ]
  
  do-plots
end

to do-plots
  set-current-plot "Proteinas pegadas" 
  set-current-plot-pen "sas-pegado" 
  plot count turtles with [shape = "triangle"] 
  set-current-plot-pen "sir-pegado" 
  plot count turtles with [shape = "circle"]
   
  set-current-plot "Estado DNA" 
  set-current-plot-pen "DNA acetilado" 
  plot count patches with [pcolor = yellow] 
  set-current-plot-pen "DNA deacetilado" 
  plot count patches with [pcolor = cyan] 

  set-current-plot "Tiempo"
  ask patches with [pycor = 0] [
    set-plot-pen-color pcolor
    if ver-proteinas [
      if any? turtles-here with [shape = "triangle"] [set-plot-pen-color red]
      if any? turtles-here with [shape = "circle"] [set-plot-pen-color blue]
    ]
    plotxy ticks pxcor 
  ]
end

@#$#@#$#@
GRAPHICS-WINDOW
215
10
735
251
25
10
10.0
1
10
1
1
1
0
1
1
1
-25
25
-10
10
1
1
1
ticks

BUTTON
77
10
135
43
random
setup\nask patches with [pycor = 0] [set pcolor one-of [yellow cyan]]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
137
10
203
43
acetilado
setup\nask patches with [pycor = 0] [set pcolor yellow]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
7
10
74
43
deacetila
setup\nask patches with [pycor = 0] [set pcolor cyan]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
124
46
187
79
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

SLIDER
16
152
188
185
afinidad-sir
afinidad-sir
0
1
0.15
.01
1
NIL
HORIZONTAL

SLIDER
16
187
188
220
cooperatividad-sir
cooperatividad-sir
0
1
0.4
.01
1
NIL
HORIZONTAL

SLIDER
16
222
188
255
afinidad-sas
afinidad-sas
0
1
0.4
.01
1
NIL
HORIZONTAL

PLOT
745
13
945
163
Proteinas pegadas
NIL
NIL
0.0
10.0
0.0
10.0
true
false
PENS
"sas-pegado" 1.0 0 -2674135 true
"sir-pegado" 1.0 0 -13345367 true

SLIDER
16
81
188
114
cantidad-sir
cantidad-sir
0
100
60
1
1
NIL
HORIZONTAL

SLIDER
16
115
188
148
cantidad-sas
cantidad-sas
0
100
60
1
1
NIL
HORIZONTAL

BUTTON
27
47
88
80
nuclea
ask patch 0 0 [\nset pcolor cyan\nsprout 1 [set shape \"circle\" set color blue]]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

SLIDER
14
297
187
330
deacetilacion-sir
deacetilacion-sir
0
1
0.5
.01
1
NIL
HORIZONTAL

SLIDER
14
332
186
365
acetilacion-sas
acetilacion-sas
0
1
0.5
.01
1
NIL
HORIZONTAL

PLOT
745
170
945
320
Estado DNA
NIL
NIL
0.0
10.0
0.0
10.0
true
false
PENS
"DNA acetilado" 1.0 0 -1184463 true
"DNA deacetilado" 1.0 0 -11221820 true

SLIDER
15
367
187
400
despegado-sir
despegado-sir
0
.1
0.015
.001
1
NIL
HORIZONTAL

SLIDER
15
401
187
434
despegado-sas
despegado-sas
0
.1
0.001
.001
1
NIL
HORIZONTAL

PLOT
215
254
737
444
Tiempo
NIL
NIL
0.0
10.0
-26.0
26.0
true
false
PENS
"acetilado" 1.0 2 -1184463 true
"deacetilado" 1.0 2 -11221820 true
"sir" 1.0 2 -13345367 true
"sas" 1.0 2 -2674135 true

SLIDER
16
260
187
293
cooperatividad-sas
cooperatividad-sas
0
1
0.1
.01
1
NIL
HORIZONTAL

SWITCH
748
325
900
358
ver-proteinas
ver-proteinas
0
1
-1000

@#$#@#$#@
WHAT IS IT?
-----------
Los fenomenos epigeneticos son una forma mas de transmicion de informacion dentro de la celula, sin embargo esta informacion es transmitida por las proteinas, no por el codigo genetico.

Este modelo ilustra la competencia entre el silenciamiento causado por la deacetilasa sir2 (azul) y la activacion causada por la acetilasa sas2 (rojo).


HOW IT WORKS
------------
Se supone que el DNA es un laticce que puede estar en dos estados silenciado (cyan) y activo (amarrillo). Las proteinas viajan aleatoriamente por el medio, hasta que encuentran el DNA y se pegan a el con una probabilidad dada. Sir2 (azul) y Sas2 (rojo) compiten por los sitios deacetilados (cyan). Sir2 vuelve sus vecinas deacetiladas, mientras que sas2 vuelve los sitios vecinos acetilados. Existe un fenomeno e cooperatividad especialmente fuerte en sir2, que implica que si hay ua proteina pegada al DNA en un sitio vecino su probabilidad de unirse al DNA se incrementa.


HOW TO USE IT
-------------
El modelo del Epigenator incluiria empezar con una cadena totalmente acetilada, despues iniciar la nucleacion.


THINGS TO NOTICE
----------------
El fenomeno de nucleacion es esencial para mantener una zona silenciada, sin el el sistema tiende a eliminar los sitios acetilados y por lo tanto los sitios de union a sir2.


THINGS TO TRY
-------------



EXTENDING THE MODEL
-------------------
Agregar polimerasa y verificar que tanto se expresan genes a diferentes distancias del sitio de nucleacion.


NETLOGO FEATURES
----------------



RELATED MODELS
--------------


CREDITS AND REFERENCES
----------------------
Modelo realizado como parte del Epigenator para el 1er Taler de Biologia Sintetica
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
0
Rectangle -7500403 true true 151 225 180 285
Rectangle -7500403 true true 47 225 75 285
Rectangle -7500403 true true 15 75 210 225
Circle -7500403 true true 135 75 150
Circle -16777216 true false 165 76 116

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 4.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 1.0 0.0
0.0 1 1.0 0.0
0.2 0 1.0 0.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
