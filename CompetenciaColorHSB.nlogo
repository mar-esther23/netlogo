turtles-own [ energy hsb-color differ]
patches-own [ hsb-pcolor ]

to setup
  ;; (for this model to work with NetLogo's new plotting features,
  ;; __clear-all-and-reset-ticks should be replaced with clear-all at
  ;; the beginning of your setup procedure and reset-ticks at the end
  ;; of the procedure.)
  __clear-all-and-reset-ticks
  set-default-shape turtles "turtles-special"
  ;;create grass
  ask patches [
    set hsb-pcolor random 255
    set pcolor (hsb hsb-pcolor 255 200) ]
  ;;create turtles
  crt initial-turtles * 100 [
    set hsb-color random 255
    set color (hsb hsb-color 255 255)
    setxy random-xcor random-ycor
    set energy 40 ]
  ;;plot
  plots
  ;;save to file
  if save [
    file-open "resultados.txt"
    write food-energy write food-range write reproduction write repro-energy
    if species [write species-range] write range-grass
    write muta-grass write muta-turtles print ""
    file ]
end

to go
  ;move-turtles
  ask turtles [ right random 360 forward 1 
    set energy (energy - 1)]
  eat-grass
  if reproduction = "asexual" [reproduce-turtles-asexual]
  if reproduction = "random" [reproduce-turtles-random]
  if reproduction = "max-energy" [reproduce-turtles-energy]
  if reproduction = "same-color" [reproduce-turtles-same]
  if reproduction = "different-color" [reproduce-turtles-different]
  ;die
  ask turtles with [energy <= 0] [die]
  plots
  reproduce-grass ;; done
  tick
  if save [ file ]
end



to-report difference [a b]
  set b  abs (b - a)
  let c abs (255 - b)
  ifelse b < c
    [report b]
    [report c]
end

to-report mutate-hsb [old]
  ;elegir nuevo color con distribucion normal alrededor del actual
  let new random-normal old 122.5
  ;normalizar
  while [new > 255] [set new (new - 255) ]
  while [new < 0] [ set new (new + 255) ]
  report round new
end

to-report middle-hsb [a b];;para reproduccion sexual el hijo tiene color intermedio
  let c (a + b) / 2 ;;c <= 255
  ;;if dif(a b) > 122.5 that is not the middle point.
  if (difference a b) > 122.5
    [ set c (c + 122.5) ]
  report c 
end



to eat-grass
  ask turtles [
    if pcolor != black [
      ;how diferent is food
      let dif difference hsb-color hsb-pcolor
      if dif <= food-range [
        set pcolor black set hsb-pcolor "null" 
        ;ponder energy obtained from food
        ;more similar, more energy
        set energy (energy + round (food-energy * (1 - dif / food-range)))
    ]]
  ]
end

to reproduce-turtles-asexual
  ask turtles with [energy > repro-energy] [
    set energy (energy - repro-energy)
    hatch 1 [
      set energy (repro-energy / 2)
      setxy random-xcor random-ycor
      ;mutate
      if random-float 1 < muta-turtles [
        set hsb-color mutate-hsb (hsb-color)
        set color (hsb hsb-color 255 255) ]
    ]
  ]
end

to reproduce-turtles-random
  ask turtles with [energy > repro-energy] [
    ;;chose mate
    let mate one-of (other turtles in-radius 1)
    ;;verify that a mate exists
    if mate != nobody [
      set energy (energy - repro-energy)
      ;;combine genomes
      let new-hsb middle-hsb hsb-color ([hsb-color] of mate)
      ;;create new turtle
      hatch-sexual new-hsb
    ]
  ]
end

to reproduce-turtles-energy
  ask turtles with [energy > repro-energy] [
    ;;chose mate
    let mate one-of (other turtles in-radius 1 with-max [energy])
    ;;verify that a mate exists
    if mate != nobody [
      set energy (energy - repro-energy)
      ;;combine genomes
      let new-hsb middle-hsb hsb-color ([hsb-color] of mate)
      ;;create new turtle
      hatch-sexual new-hsb
    ]
  ]
end

to reproduce-turtles-same
  ask turtles with [energy > repro-energy] [
    ;;chose mate
    ask other turtles in-radius 1 [ set differ difference hsb-color ([hsb-color] of myself) ]
    let mate one-of (other turtles in-radius 1 with-min [differ])
    ask other turtles in-radius 1 [ set differ 0 ]
    ;;check if it outside of species-range
    if species and differ > species-range [ set mate nobody ]
    ;;verify that a mate exists
    if mate != nobody [
      set energy (energy - repro-energy)
      ;;combine genomes
      let new-hsb middle-hsb hsb-color ([hsb-color] of mate)
      ;;create new turtle
      hatch-sexual new-hsb
    ]
  ]
end

to reproduce-turtles-different
  ask turtles with [energy > repro-energy] [
    ;;chose mate
    ask other turtles in-radius 1 [ set differ difference hsb-color ([hsb-color] of myself) ]
    let mate one-of (other turtles in-radius 1 with-max [differ])
    ask other turtles in-radius 1 [ set differ 0 ]
    ;;check if it outside of species-range
    if species and differ < species-range [ set mate nobody ]
    ;;verify that a mate exists
    if mate != nobody [
      set energy (energy - repro-energy)
      ;;combine genomes
      let new-hsb middle-hsb hsb-color ([hsb-color] of mate)
      ;;create new turtle
      hatch-sexual new-hsb
    ]
  ]
end

to hatch-sexual [new-hsb]
  hatch 1 [
    set hsb-color new-hsb
    set energy (repro-energy / 2)
    ;setxy random-xcor random-ycor
    ;mutate
    if random-float 1 < muta-turtles [
      set hsb-color mutate-hsb (hsb-color)
      ]
    set color (hsb hsb-color 255 255)
  ]
end

to reproduce-grass
  ask patches with [pcolor = black] [
    ;;chose a living neighbor
    let new one-of patches in-radius range-grass with [pcolor != black]
    ;; copy the information of that neighbor
    if new != nobody [
      set hsb-pcolor [hsb-pcolor] of new
      ;mutate
      if random-float 1 < muta-grass [
        set hsb-pcolor mutate-hsb (hsb-pcolor)]
    ]]
  ;;change color of patches
  ask patches with [hsb-pcolor != "null"] [set pcolor (hsb hsb-pcolor 255 200) ]
  ask patches with [hsb-pcolor = "null"] [set pcolor black ]
end

to plots
  set-current-plot "Totals"
  set-current-plot-pen "turtles"
  plot count turtles
  set-current-plot-pen "grass"
  plot count patches with [pcolor != black]
  
  set-current-plot "Distribution"
  set-plot-x-range 0 255
  set-current-plot-pen "turtles"
  set-histogram-num-bars bars
  histogram [hsb-color] of turtles
  set-current-plot-pen "grass"
  set-histogram-num-bars bars
  histogram [hsb-pcolor] of patches
  
  set-current-plot "plano"
  ;if ticks mod 10 = 0 [clear-plot]
  ;set-current-plot-pen "default"
  ;plotxy count turtles count patches with [pcolor != black]
  
  let i 0
  let r round (2 * 255 / bars)
  while [i < 255] [
    create-temporary-plot-pen (word i)
    set-plot-pen-mode 2
    set-plot-pen-color (approximate-hsb i 255 255)
    plotxy (count turtles with [(hsb-color >= i) and (hsb-color < (i + r))]) (count patches with [(hsb-pcolor != "null") and (hsb-pcolor >= i) and (hsb-pcolor < (i + r))])
  set i i + r]
end


to file 
  file-print ticks
  let i 0
  ;; turtles
  while [i <= 255] [
    file-write (count turtles with [hsb-color = i])
    set i i + 1
    ]
  file-print " "
  ;; grass
  set i 0
  while [i <= 255] [
    file-write (count turtles with [hsb-pcolor = i])
    set i i + 1
     ] 
  file-print " "
  file-flush ;;save
end
@#$#@#$#@
GRAPHICS-WINDOW
148
10
554
437
16
16
12.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

MONITOR
579
10
636
55
turtles
count turtles
17
1
11

MONITOR
642
10
699
55
grass
count patches with [ pcolor != black ] 
17
1
11

BUTTON
8
10
71
43
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
79
10
142
43
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
1

SLIDER
8
79
141
112
food-energy
food-energy
0
100
15
1
1
NIL
HORIZONTAL

SLIDER
9
334
142
367
muta-grass
muta-grass
0
1
0.1
.01
1
NIL
HORIZONTAL

PLOT
561
59
761
194
totals
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"turtles" 1.0 0 -2674135 true "" ""
"grass" 1.0 0 -10899396 true "" ""

PLOT
763
59
963
194
distribution
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"turtles" 1.0 1 -2674135 true "" ""
"grass" 1.0 1 -10899396 true "" ""

SLIDER
704
17
796
50
bars
bars
0
100
51
1
1
NIL
HORIZONTAL

SLIDER
9
368
142
401
muta-turtles
muta-turtles
0
1
0.1
.01
1
NIL
HORIZONTAL

SLIDER
8
113
141
146
food-range
food-range
0
255
35
1
1
NIL
HORIZONTAL

SLIDER
8
195
142
228
repro-energy
repro-energy
0
100
50
2
1
NIL
HORIZONTAL

SLIDER
9
300
142
333
range-grass
range-grass
0
16
1
1
1
NIL
HORIZONTAL

BUTTON
28
404
116
437
extintion
ask turtles [ if random-float 1 < 0.1 [die] ]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
8
45
141
78
initial-turtles
initial-turtles
0
20
6
.5
1
NIL
HORIZONTAL

SWITCH
868
17
958
50
save
save
1
1
-1000

PLOT
571
197
953
461
plano
turtle
grass
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 2 -16777216 true "" ""

CHOOSER
8
148
142
193
reproduction
reproduction
"asexual" "random" "max-energy" "same-color" "different-color"
3

SWITCH
19
264
132
297
species
species
0
1
-1000

SLIDER
8
229
142
262
species-range
species-range
0
100
35
1
1
NIL
HORIZONTAL

BUTTON
799
17
866
50
clear
set-current-plot \"plano\" clear-plot
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
## WHAT IS IT?

Los seres vivos afectan el ecosistema.
Los seres vivos alteran el ambiente, sin embargo no tienen el mismo impacto en todas las variables de este. Dada la complejidad de las relaciones entre los seres vivos y su ecosistema no es facil predecir cuales seran los efectos de estos sobre el ambiente. Se realizo un modelo depredador-presa con una presa inmovil (pasto) y un depredador movil (tortuga). Tanto el depredador como la presa se les asigno un fenotipo: un color en la escala HSB. A partir de este fenotipo se fijo una restreccion en el sistema: los depredadores solo pueden consumir una presa de un color cercano al suyo.
Se inicio la simulacion asignando colores aleatorios a los agentes. Se puede notar que se generan subpoblaciones de colores especificos, desapareciendo los individuos con colores intermedios.


## HOW IT WORKS

Este es un sistema depredador presa, con la peculiaridad de que cada tortuga tiene un color en la escala cilindrica HSB. Las torutgas solo pueden comer pasto que sea parecido a su color.  
Se incluyen diferentes tipos de reproduccion para las tortugas. Si es asexual la tortuga hereda el color del progenitor con una probabilidad de mutacion. Si es sexual se elige el color intermedio de los padres. El pasto es asexual.  
El pasto cuando ha sido comido deja un espacio negro, ese espacio negro puede ser colonizado por alguno de sus vecinos.

## HOW TO USE IT

Especies evita que se reproducscan con tortugas demasiado diferentes a ellas mismas.  
Range-grass determina que tan lejos puede estar el pasto que colonisara un patch vacio.

## THINGS TO NOTICE

Cambio de las curvas segun el modo de reproduccion.  
Se crean ciclos depredador-presa muy estables! Comparar con otros modelos basados en agentes, eso no es trivial.

## THINGS TO TRY

Empieza con una poblacion de un solo color

## EXTENDING THE MODEL

So much to do

## NETLOGO FEATURES

## RELATED MODELS

CompetenciaRGBSexual

## CREDITS AND REFERENCES

Creado por Mariana Esther Martinez Sanchez. Por favor citame si usas este modelo.
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

turtles-special
true
0
Polygon -16777216 true false 150 0 45 255 150 210 255 255
Polygon -7500403 true true 150 15 60 240 150 195 240 240

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
NetLogo 5.0.3
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
