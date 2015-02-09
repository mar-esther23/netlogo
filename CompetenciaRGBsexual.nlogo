turtles-own [ energy hsb-color rgb-color differ]
patches-own [ hsb-pcolor rgb-pcolor]

to setup
  ca
  set-default-shape turtles "turtles-special"
  ;;create grass
  ask patches [
    ;define rgb-genome
    set rgb-pcolor (list random 256 random 256 random 256)
    ;convert to hsb
    set hsb-pcolor rgb-to-hsb rgb-pcolor
    ;set color-fenotype
    set pcolor hsb hsb-pcolor 255 200
    ]
  ;;create turtles
  crt initial-turtles * 100 [
    setxy random-xcor random-ycor
    set rgb-color (list random 256 random 256 random 256)
    set hsb-color rgb-to-hsb rgb-color
    set color hsb hsb-color 255 255
    set energy 40
    ]
  ;;plot
  plots
  ;;save to file
  if save [
    file-open "resultados.txt"
    file]
end

to go
  ;;ask turtles [set label energy]
  ;;ask turtles with [energy > 40] [set size 2]
  ;;ask turtles with [energy <= 40]  [set size 1] 
  ;move-turtles
  ask turtles [ right random 360 forward 1 
    set energy (energy - 1)]
  eat-grass
  if reproduction = "asexual" [reproduce-turtles-asexual]
  if reproduction = "max-energy" [reproduce-turtles-max-energy]
  if reproduction = "same-color" [reproduce-turtles-same-color]
  if reproduction = "different-color" [reproduce-turtles-different-color]
  if reproduction = "random" [reproduce-turtles-random]
  ;die
  ask turtles with [energy <= 0] [die]
  plots
  reproduce-grass
  tick
  if save [
    file ]
end




to-report rgb-to-hsb [data]
  let r item 0 data
  let g item 1 data
  let b item 2 data
  ;;calcular diferencia
  let c  max data - min data
  let res 0
  ;;calcular angulo
  ifelse c = 0 [  set res 0 ]
    [ifelse r >= g and r >= b [ set res (255 / 6 * ( (g - b) / c mod 6)) ]
      [ifelse g >= r and g >= b [ set res (255 / 6 * ( ( b - r ) / c + 2)) ]
        [if b >= r and b >= g [ set res (255 / 6 * ( ( r - g ) / c + 4)) ]
    ]]]
  report round res
end

to-report difference [a b]
  set b  abs (b - a)
  let c abs (255 - b)
  ifelse b < c
    [report b]
    [report c]
end

to-report new-color [old]
  ;elegir nuevo color con distribucion normal alrededor del actual
  let new random-normal old 122.5
  ;normalizar
  while [new > 255] [set new (new - 255) ]
  while [new < 0] [ set new (new + 255) ]
  report round new
end




to eat-grass
  ask turtles [
    if pcolor != black [
      ;how diferent is food
      let dif difference hsb-color hsb-pcolor
      if dif <= food-range [
        set pcolor black
        set hsb-pcolor "null" set rgb-pcolor "null"
        ;ponder energy obtained from food
        ;more similar, more energy
        set energy (energy + round (food-energy * (1 - dif / food-range)))
    ]]
  ]
end

to reproduce-turtles-asexual
  ask turtles with [energy > reproduce-energy] [
    set energy (energy - reproduce-energy)
    hatch 1 [
      set energy (reproduce-energy / 2)
      ;mutate
      if random-float 1 < mutate-turtles [
        let i random 3 ;change one gen
        let temp new-color (item i rgb-color) ;new color
        set rgb-color (replace-item i rgb-color temp) ;replace
        ;actualize hsb
        set hsb-color rgb-to-hsb rgb-color
        set color hsb hsb-color 255 255
        ]
    ]]
end

to reproduce-turtles-max-energy
  ask turtles with [energy > reproduce-energy] [
    ;chose mate
    let mate one-of (other turtles in-radius 1 with-max [energy])
    ;check mate exists
    if mate != nobody [
      set energy (energy - reproduce-energy)
      ;;combine genomes
      set mate (turtle-set self mate)
      ;;create new turtle
      hatch-sexual ([item 0 rgb-color] of one-of mate) ([item 1 rgb-color] of one-of mate) ([item 2 rgb-color] of one-of mate)
      ]
  ]
end

to reproduce-turtles-same-color
  ask turtles with [energy > reproduce-energy] [
    ;chose mate
    ask other turtles in-radius 1 [ set differ difference hsb-color ([hsb-color] of myself) ]
    let mate one-of (other turtles in-radius 1 with-min [differ])
    ask other turtles in-radius 1 [ set differ 0 ]
    ;;check if it outside of species-range
    if species and differ > species-range [ set mate nobody ]
    ;check mate exists
    if mate != nobody [
      ;only mom losses energy... men!
      set energy (energy - reproduce-energy)
      ;;combine genomes
      set mate (turtle-set self mate)
      ;;create new turtle
      hatch-sexual ([item 0 rgb-color] of one-of mate) ([item 1 rgb-color] of one-of mate) ([item 2 rgb-color] of one-of mate)
      ]
  ]
end

to reproduce-turtles-different-color
  ask turtles with [energy > reproduce-energy] [
    ;chose mate
    ask other turtles in-radius 1 [ set differ difference hsb-color ([hsb-color] of myself) ]
    let mate one-of (other turtles in-radius 1 with-max [differ])
    ask other turtles in-radius 1 [ set differ 0 ]
    ;;check if it outside of species-range
    if species and differ < species-range [ set mate nobody ]
    ;check mate exists
    if mate != nobody [
      set energy (energy - reproduce-energy)
      ;;combine genomes
      set mate (turtle-set self mate)
      let r [item 0 rgb-color] of one-of mate
      let g [item 1 rgb-color] of one-of mate
      let b [item 2 rgb-color] of one-of mate
      ;;create new turtle
      hatch-sexual ([item 0 rgb-color] of one-of mate) ([item 1 rgb-color] of one-of mate) ([item 2 rgb-color] of one-of mate)
      ]
  ]
end

to reproduce-turtles-random
  ask turtles with [energy > reproduce-energy] [
    ;chose mate
    let mate one-of (other turtles in-radius 1)
    ;check mate exists
    if mate != nobody [
      set energy (energy - reproduce-energy)
      ;;combine genomes
      set mate (turtle-set self mate)
      ;;create new turtle
      hatch-sexual ([item 0 rgb-color] of one-of mate) ([item 1 rgb-color] of one-of mate) ([item 2 rgb-color] of one-of mate)
      ]
  ]
end

to hatch-sexual [r g b] ;;turtle procedure
  hatch 1 [
    set rgb-color (list r g b) ;set genome
    ;;mutate
    if random-float 1 < mutate-turtles [
      let i random 3 ;change one gen
      let temp new-color (item i rgb-color) ;new color
      set rgb-color replace-item i rgb-color temp ;replace
    ]
    ;create fenotype color
    set hsb-color rgb-to-hsb rgb-color
    set color hsb hsb-color 255 255
    set energy (reproduce-energy / 2)
  ]
end

to reproduce-grass
  ask patches with [pcolor = black] [
    ;;chose a living neighbor
    let new one-of patches in-radius range-grass with [pcolor != black]
    ;; copy the information of that neighbor
    if new != nobody [
      set rgb-pcolor [rgb-pcolor] of new
      ;;mutate
      if random-float 1 < mutate-grass [
        let i random 3 ;change one gen
        let temp new-color (item i rgb-pcolor) ;new color
        set rgb-pcolor replace-item i rgb-pcolor temp ;replace
        ]
      ;actualize hsb
      set hsb-pcolor rgb-to-hsb rgb-pcolor
    ]
  ]
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
end

to kill
  ask turtles [
    if random-float 1 < extintion-rate [die]
  ]
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

to show-rgb
  ask turtles [set color rgb-color]
  ask patches with [rgb-pcolor != "null"] [set pcolor rgb-pcolor]
end

to show-hsb
  ask turtles [set color hsb hsb-color 255 255]
  ask patches with [hsb-pcolor != "null"] [set pcolor hsb hsb-pcolor 255 200]
end
@#$#@#$#@
GRAPHICS-WINDOW
205
10
635
461
10
10
20.0
1
10
1
1
1
0
1
1
1
-10
10
-10
10
0
0
1
ticks

MONITOR
669
13
726
58
turtles
count turtles
17
1
11

MONITOR
730
13
787
58
grass
count patches with [ pcolor != black ] 
17
1
11

BUTTON
34
10
97
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

BUTTON
105
10
168
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

SLIDER
19
112
191
145
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
17
366
189
399
mutate-grass
mutate-grass
0
1
0.1
.01
1
NIL
HORIZONTAL

PLOT
670
63
870
198
totals
NIL
NIL
0.0
10.0
0.0
10.0
true
false
PENS
"turtles" 1.0 0 -2674135 true
"grass" 1.0 0 -10899396 true

PLOT
670
200
870
335
distribution
NIL
NIL
0.0
10.0
0.0
10.0
true
false
PENS
"turtles" 1.0 1 -2674135 true
"grass" 1.0 1 -10899396 true

SLIDER
682
417
854
450
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
17
400
189
433
mutate-turtles
mutate-turtles
0
1
0.05
.01
1
NIL
HORIZONTAL

SLIDER
19
146
191
179
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
21
228
193
261
reproduce-energy
reproduce-energy
0
100
50
2
1
NIL
HORIZONTAL

SLIDER
17
332
189
365
range-grass
range-grass
0
16
3
1
1
NIL
HORIZONTAL

BUTTON
716
344
804
377
extintion
kill
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

SLIDER
683
382
855
415
extintion-rate
extintion-rate
0
1
0.9
.05
1
NIL
HORIZONTAL

SLIDER
19
78
191
111
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
51
44
154
77
save
save
1
1
-1000

BUTTON
26
434
99
467
NIL
show-rgb
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
102
434
177
467
NIL
show-hsb
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

CHOOSER
31
182
182
227
reproduction
reproduction
"asexual" "max-energy" "same-color" "different-color" "random"
0

SLIDER
21
264
193
297
species-range
species-range
0
100
35
1
1
NIL
HORIZONTAL

SWITCH
48
298
161
331
species
species
1
1
-1000

@#$#@#$#@
WHAT IS IT?
-----------
Los seres vivos afectan el ecosistema.


HOW IT WORKS
------------
Este programa hereda muchas cosas de competenciaHSB. La principal diferencia es que ahora los organismos tienen un genoma con 3 colores correspondientes a la escala RGB (genotipo). A partir de ese genoma se mapea a HSB (fenotipo).
Este es un sistema depredador presa, con la peculiaridad de que cada tortuga tiene un color en la escala RGB. Las torutgas solo pueden comer pasto que sea parecido a su color.
Se incluyen diferentes tipos de reproduccion para las tortugas. Si es asexual la tortuga hereda el color del progenitor con una probabilidad de mutacion. Si es sexual se elige el color intermedio de los padres. El pasto es asexual.
El pasto cuando ha sido comido deja un espacio negro, ese espacio negro puede ser colonizado por alguno de sus vecinos.


HOW TO USE IT
-------------
Especies evita que se reproducscan con tortugas demasiado diferentes a ellas mismas.
Range-grass determina que tan lejos puede estar el pasto que colonisara un patch vacio.

THINGS TO NOTICE
----------------
Cambio de las curvas segun el modo de reproduccion.
Se crean ciclos depredador-presa muy estables! Comparar con otros modelos basados en agentes, eso no es trivial.


THINGS TO TRY
-------------
Empieza con una poblacion de un solo color


EXTENDING THE MODEL
-------------------
So much to do


NETLOGO FEATURES
----------------
Casi es un algoritmo genetico.


RELATED MODELS
--------------
CompetenciaRGBSexual

CREDITS AND REFERENCES
----------------------
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
NetLogo 4.1
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
