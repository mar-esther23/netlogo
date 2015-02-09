globals [
  on-color
  off-color
  stable-flag
  a-black
  a-white
  a-red
  a-yellow
  ]

turtles-own [
  funcion ;list of interactions
  neighborhood ;list of regulators
  value ;bool value of node
  new-value ;temp bool value of node
  stable ;variable for comparisons
  ]


to new-net
  clear-all
  ask patches [set pcolor cyan]
  set-default-shape turtles "circle"
  set on-color white
  set off-color black
  set stable-flag false
  crt n-nodes [   ;create nodes
     set value one-of [true false]
     set color node-color
     set neighborhood (list)
     set funcion (list)
     ;set size 2
     ]
  ask-concurrent turtles [
    create-links-from n-of n-links other turtles ;create coneccions
    set neighborhood sort ([end1] of my-in-links) ;create list of regulators
    ;asign function
    repeat 2 ^ n-links [
      ifelse random-float 1 < p-1
        [set funcion lput true funcion]
        [set funcion lput false funcion]
      ]
    ]
  order-network   ;order nodes
  set a-black (list 0 0 0 0 0 0 0 0 0 0)
  set a-white (list 0 0 0 0 0 0 0 0 0 0)
  set a-red   (list 0 0 0 0 0 0 0 0 0 0)
  set a-yellow (list 0 0 0 0 0 0 0 0 0 0)
  do-plots
  reset-ticks
end

to run-net
  set stable-flag true
  ask turtles [    ;determinate value of neighbors
    let i 0
    foreach neighborhood [
      if [value] of ?
        [set new-value new-value + (1 * (2 ^ i))] ; new value as a temp var to save the function
      set i (i + 1)
      ]
    ]
  ask turtles [  ;determinate new value of turtles
    set new-value item new-value funcion    ;find value in function
    if value != new-value     ;check for stability
      [ set stable-flag false ]
    set value new-value
    set color node-color
    set new-value 0
  ]
  if (count turtles with [color = red] + count turtles with [color = yellow]) = 0  ;check cycles
    [ set on-color white set off-color black ]
  if stable-flag = true  [ask turtles [set stable value]]
  if ticks = 2000 [stop] 
  do-plots
  tick
end

to order-network
  if network-display = "circle"
    [ layout-circle turtles (n-nodes / 5) ]
  if network-display = "tree" [ 
    ask turtles [setxy random-xcor random-ycor]
    layout-radial turtles links (one-of turtles)
    ]
  if network-display = "tutte" [ 
    ask turtles [setxy random-xcor random-ycor]
    repeat n-nodes [ layout-tutte (turtles with [my-out-links = 1]) links 12 ] 
    ]
  if network-display = "spring"
    [ repeat (n-nodes * 3) [ layout-spring turtles links 0.2 5 1 ] ]
  if network-display = "random" [ 
    ask turtles [setxy random-xcor random-ycor]
    ]
end

to new-state
  set on-color white
  set off-color black
  set stable-flag false
  ask turtles [
    set value one-of [true false]
    set color node-color
    ;set size 2
    ]
end

to change-nodes
  set on-color yellow
  set off-color red
  set stable-flag false
  ask turtles [set stable value]
  ask n-of change turtles [
    set value (not value)
    set color node-color
    set size 1.5
    ]
end

to change-functions
  set on-color yellow
  set off-color red
  set stable-flag false
  ask turtles [set stable value]
  ask n-of (change / n-links) turtles [
    ask my-in-links [die]
    create-links-from n-of n-links other turtles [set color black]
    ;create list of regulators
    set neighborhood sort ([end1] of my-in-links)
    ]
end

to do-plots
  ; this code calculates the average count of nodes
  set a-black remove-item 0 a-black
  set a-black lput (count turtles with [color = black] / count turtles) a-black
  set a-white remove-item 0 a-white
  set a-white lput (count turtles with [color = white] / count turtles) a-white
  set a-red remove-item 0 a-red
  set a-red lput (count turtles with [color = red] / count turtles) a-red
  set a-yellow remove-item 0 a-yellow
  set a-yellow lput (count turtles with [color = yellow] / count turtles) a-yellow
  if show-state
    [print state]
end

to-report state ;observer reporter
  let s 0
  ask turtles [
    if value [set s s + (1 * 2 ^ who) ]
    ]
  report s
end

to-report node-color ;turlte reporter
  ifelse value = stable
    [
    ifelse value 
      [report white]
      [report black]
    ]
    [
    ifelse value 
      [report on-color]
      [report off-color]
    ]
end
@#$#@#$#@
GRAPHICS-WINDOW
179
10
599
451
20
20
10.0
1
10
1
1
1
0
0
0
1
-20
20
-20
20
0
0
1
ticks
30.0

BUTTON
4
16
88
49
Network
new-net
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
2
157
174
190
n-nodes
n-nodes
0
100
100
1
1
NIL
HORIZONTAL

SLIDER
3
192
175
225
n-links
n-links
0
5
3
1
1
NIL
HORIZONTAL

SLIDER
3
228
175
261
p-1
p-1
0
1
0.5
0.01
1
NIL
HORIZONTAL

BUTTON
3
52
58
85
Once
run-net\ntick
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
59
52
114
85
Run
;ifelse stable-flag [ stop ] [ run-net ]\nrun-net
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
3
264
175
297
change
change
0
50
6
1
1
NIL
HORIZONTAL

BUTTON
26
88
152
121
Change-Nodes
change-nodes
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
19
302
155
335
show-state
show-state
1
1
-1000

BUTTON
90
16
174
49
New State
new-state
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
7
341
116
386
network-display
network-display
"circle" "tree" "tutte" "spring" "random"
1

BUTTON
121
347
176
380
Display
order-network
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
26
122
153
155
Change-Functions
change-functions
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
119
52
174
85
Auto
new-net\nrepeat 1000 [run-net]\nchange-nodes\nrepeat 1000 [run-net]\nnew-net\nrepeat 1000 [run-net]\nchange-functions\nrepeat 1000 [run-net]
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
602
10
802
299
Network state
nodes state
time
0.0
100.0
-2000.0
0.0
false
false
"set-plot-x-range 0 n-nodes\nset-plot-y-range -2000 0" "ask turtles [\nset-plot-pen-color color\nplotxy who (- ticks)\n]"
PENS
"state" 1.0 2 -16777216 true "" ""

PLOT
602
301
802
451
Average nodes state
time
% nodes
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"off" 1.0 0 -16777216 true "" "plot mean a-black"
"on" 1.0 0 -7500403 true "" "plot mean a-white"
"c-off" 1.0 0 -2674135 true "" "plot mean a-red"
"c-on" 1.0 0 -1184463 true "" "plot mean a-yellow"

@#$#@#$#@
## WHAT IS IT?

A Boolean network consists of a discrete set of Boolean variables (TRUE or FALSE) each of which has a boolean function (possibly different for each variable) assigned to it which takes inputs from a subset of those variables and output that determines the state of the variable it is assigned to. This set of functions in effect determines a topology (connectivity) on the set of variables, which then become nodes in a network. Usually, the dynamics of the system is taken as a discrete time series where the state of the entire network at time t+1 is determined by evaluating each variable's function on the state of the network at time t. This may be done synchronously or asynchronously.

A random Boolean network (RBN) is one that is randomly selected from the set of all possible boolean networks of a particular size, N. One then can study statistically, how the expected properties of such networks depend on various statistical properties of the ensemble of all possible networks. I.e. how does the behavior change as the average connectivity is changed.

## HOW IT WORKS

Each node in the network is connected to a number (n-links) of other nodes. The value of each node is a random function that depends of the connected nodes. The proporsion of 1's in the functions is given by p-1. The value and the function of a node can be altered.

## HOW TO USE IT

Network: generate a network with "n-nodes" with "n-links" conections per node.
New State: set a new value (True or False) of each node.
Change-nodes: randomly change the value of "change" nodes.
Change-functions:  randomly change the functions of "change" nodes.
Display: change the layout of the network.
Once: apply the functions of the network once.
Run: continously apply the functions of the network.
Auto: Generate a new network, run, change nodes, run, reset the state, change functions, run.
Show-state: shows the value of all the nodes in decimal format.


## EXTENDING THE MODEL

Improve cycle detection.

## NETLOGO FEATURES

This model makes extensive use of lists. 

## RELATED MODELS

Random Boolean Network by David Weintrop


## CREDITS AND REFERENCES

Made by: Mariana Esther Martinez Sanchez.
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
NetLogo 5.0.3
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
