globals [
]

turtles-own [
  score
  strategy
  defect-now?
  partner-defected? ;;action of the partner
  partner           ;;WHO of my partner (nobody if not partnered)
  partner-history   ;;a list containing information about past interaction
]

patches-own [
  p-score
  p-strategy
  p-defect-now?
  p-partner-defected? ;;action of the partner
  p-partner           ;;WHO of my partner (nobody if not partnered)
  p-partner-history   ;;a list containing information about past interaction
]




to setup
  clear-all
  if turtles? [ add-turtles ]
  if patches? [ add-patches ]
  reset-ticks
end

to add-turtles
  crt n-cooperate [ 
    set strategy "cooperate" 
    set defect-now? False
    set color blue
    init_turtle ]
  crt n-defect [ 
    set strategy "defect" 
    set defect-now? True
    set color red
    init_turtle ]
  crt n-tit-for-tat [ 
    set strategy "tit-for-tat" 
    set defect-now? False
    set color lime
    init_turtle ]
  crt n-random [ 
    set strategy "random" 
    set defect-now? one-of [True False]
    set color gray - 1 
    init_turtle ]
end
  
to init_turtle ;;turtle procedure
    set score 10 
    set partner nobody
    set partner-history false
    setxy random-xcor random-ycor
end

to add-patches
  if (n-cooperate + n-defect + n-tit-for-tat + n-random) + 1 > (count patches with [ pcolor = black ] + 1)
    [ error "Not enough free patches" ]
  ask n-of n-cooperate patches with [ pcolor = black ] [
    set p-strategy "cooperate" 
    set p-defect-now? False
    set pcolor blue
    init_patch ]
  ask n-of n-defect patches with [ pcolor = black ] [
    set p-strategy "defect" 
    set p-defect-now? True
    set pcolor red
    init_patch ]
  ask n-of n-tit-for-tat patches with [ pcolor = black ] [
    set p-strategy "tit-for-tat" 
    set p-defect-now? False
    set pcolor lime
    init_patch ]
  ask n-of n-random patches with [ pcolor = black ] [
    set p-strategy "random" 
    set p-defect-now? one-of [True False]
    set pcolor gray - 1
    init_patch ]
end

to init_patch ;;patch procedure
    set p-score 10 
    set p-partner nobody
    set p-partner-history false
end




to go
  ;;clear last round
  ask turtles [ set partner nobody  ]
  ask patches [ set p-partner nobody ]
   
  ;;move
  ask turtles [ rt random 360 fd 1 ]
  
  ;; set partner
  if turtles? [   ask turtles [         
    set partner one-of (turtles-on neighbors) with [ partner = nobody ]
    if partner != nobody [ ask partner [ set partner myself ] ]
  ]   ]
  if patches? [   ask patches with [ pcolor != black]  [         
    set p-partner one-of (neighbors) with [ pcolor != black and p-partner = nobody ]
    if p-partner != nobody [ ask p-partner [ set p-partner myself ] ]
  ]   ]
  
  ;;play
  if turtles? [   ask-concurrent turtles with [ partner != nobody ]  [ 
    set defect-now?  select-action strategy partner-history   ;;all players select action
    set score score + payoff defect-now? [defect-now?] of partner     ;;calculate round payoff
    set partner-history [defect-now?] of partner
  ]   ]
  if patches? [   ask-concurrent patches with [ p-partner != nobody ]  [ 
    set p-defect-now?  select-action p-strategy p-partner-history   ;;all players select action
    set p-score p-score + payoff p-defect-now? [p-defect-now?] of p-partner     ;;calculate round payoff
    set p-partner-history [p-defect-now?] of p-partner
    set plabel p-score
  ]   ]
  
  ;;life and death
  if hatch? [ 
    if turtles?   [ ask turtles with [ score > reproduce] [
       set score (score - reproduce)
       hatch 1 [ init_turtle ]
    ]    ]   
    if patches?   [ ask-concurrent patches with [pcolor = black] [
        let parent one-of neighbors with [ p-score > reproduce]
        if parent != nobody [
          ask patch [pxcor] of parent [pycor] of parent [ set p-score p-score - reproduce ]
          set p-strategy [p-strategy] of parent
          set p-defect-now? [p-defect-now?] of parent
          set pcolor [pcolor] of parent
          init_patch ]
    ]   ]
    ]
  if turtles? [
    ask turtles [ set score score - decay ]
    if die? [ ask turtles with [ score < 1 ] [die] ]
  ]
  if patches? [
    ask patches [ set p-score p-score - decay ]
    if die? [ ask patches with [ p-score < 1 ] [set pcolor black] ]
  ]
  
  ;; control
  if patches? [ ask patches with [ pcolor != black ] [ set plabel p-score ] ]
  if turtles? [ ask turtles with [ color != black ] [ set label score ] ]
  if patches? and (count patches with [pcolor != black]) = 0 [ stop ]
  if turtles? and (count turtles) = 0 [ stop ]
  if (count turtles) > 10000 [ stop ]
  tick
end


to-report select-action [ r-strategy r-partner-history ]
  ;;choose an action based upon the strategy being played
  if r-strategy = "random" [ report one-of [True False] ]
  if r-strategy = "cooperate" [ report False ]
  if r-strategy = "defect" [ report True ]
  if r-strategy = "tit-for-tat" [ report r-partner-history ]
end

to-report payoff [ r-defect-now r-partner-defected ]
  ;;calculate wins and loses
  ifelse r-partner-defected [
    ifelse r-defect-now
      [ report D_D] 
      [ report C_D ]
  ] [
    ifelse r-defect-now
      [ report D_C ] 
      [ report C_C ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
303
8
733
459
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
1
1
1
ticks
30.0

BUTTON
8
19
86
62
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
85
19
173
62
go
go\n
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
138
136
264
169
n-random
n-random
0
50
0
1
1
NIL
HORIZONTAL

SLIDER
9
136
135
169
n-cooperate
n-cooperate
0
50
0
1
1
NIL
HORIZONTAL

SLIDER
9
169
135
202
n-defect
n-defect
0
50
5
1
1
NIL
HORIZONTAL

SLIDER
138
170
264
203
n-tit-for-tat
n-tit-for-tat
0
50
25
1
1
NIL
HORIZONTAL

TEXTBOX
11
236
177
460
                PAYOFF:\n                     Partner    \nTurtle        C                  D\n-----------------------------------------\n\n    C        \n\n-----------------------------------------\n\n    D       \n\n-----------------------------------------\n(C = Cooperate, D = Defect)
11
0.0
0

BUTTON
174
19
260
63
go once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
48
283
107
343
C_C
4
1
0
Number

INPUTBOX
112
283
171
343
C_D
-1
1
0
Number

INPUTBOX
48
347
107
407
D_C
5
1
0
Number

INPUTBOX
112
347
171
407
D_D
0
1
0
Number

SLIDER
186
376
289
409
reproduce
reproduce
1
100
8
1
1
NIL
HORIZONTAL

PLOT
739
10
939
160
Total
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
"random" 1.0 0 -7500403 true "" "plot count turtles with [strategy = \"random\"]"
"tit-for-tat" 1.0 0 -10899396 true "" "plot count turtles with [strategy = \"tit-for-tat\"]"
"cooperate" 1.0 0 -13345367 true "" "plot count turtles with [strategy = \"cooperate\"]"
"defect" 1.0 0 -2674135 true "" "plot count turtles with [strategy = \"defect\"]"
"p-random" 1.0 0 -7500403 true "" "plot count patches with [p-strategy = \"random\"]"
"p-tit-for-tat" 1.0 0 -10899396 true "" "plot count patches with [p-strategy = \"tit-for-tat\"]"
"p-cooperate" 1.0 0 -13345367 true "" "plot count patches with [p-strategy = \"cooperate\"]"
"p-defect" 1.0 0 -2674135 true "" "plot count patches with [p-strategy = \"defect\"]"

SWITCH
186
273
289
306
die?
die?
0
1
-1000

SWITCH
186
342
289
375
hatch?
hatch?
0
1
-1000

BUTTON
19
99
122
132
NIL
add-turtles
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
739
161
939
311
Rate
NIL
NIL
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"random" 1.0 0 -7500403 true "" "plot (count turtles with [strategy = \"random\"]) / (count turtles + 1)"
"tit-for-tat" 1.0 0 -10899396 true "" "plot (count turtles with [strategy = \"tit-for-tat\"]) / (count turtles + 1)"
"cooperate" 1.0 0 -13345367 true "" "plot (count turtles with [strategy = \"cooperate\"]) / (count turtles + 1)"
"defect" 1.0 0 -2674135 true "" "plot (count turtles with [strategy = \"defect\"]) / (count turtles + 1)"
"p-random" 1.0 0 -7500403 true "" "plot (count patches with [p-strategy = \"random\"]) / (count patches with [pcolor != black] + 1)"
"p-tit-for-tat" 1.0 0 -10899396 true "" "plot (count patches with [p-strategy = \"tit-for-tat\"]) / (count patches with [pcolor != black] + 1)"
"p-cooperate" 1.0 0 -13345367 true "" "plot (count patches with [p-strategy = \"cooperate\"]) / (count patches with [pcolor != black] + 1)"
"p-defect" 1.0 0 -2674135 true "" "plot (count patches with [p-strategy = \"defect\"]) / (count patches with [pcolor != black] + 1)"

PLOT
739
312
939
462
Cooperate Defect
NIL
NIL
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"defect" 1.0 0 -2674135 true "" "plot (count turtles with [defect-now? = True]) / (count turtles + 1)"
"cooperate" 1.0 0 -13345367 true "" "plot (count turtles with [defect-now? = False]) / (count turtles + 1)"
"p-defect" 1.0 0 -2674135 true "" "plot (count patches with [p-defect-now? = True]) / (count patches with [pcolor != black] + 1)"
"p-cooperate" 1.0 0 -13345367 true "" "plot (count patches with [p-defect-now? = False]) / (count patches with [pcolor != black] + 1)"

SWITCH
16
64
127
97
turtles?
turtles?
1
1
-1000

SWITCH
141
64
257
97
patches?
patches?
1
1
-1000

SLIDER
186
307
290
340
decay
decay
0
10
2
1
1
NIL
HORIZONTAL

BUTTON
148
99
251
132
NIL
add-patches
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

This model is a multiplayer version of the iterated prisoner's dilemma with reproduction and death. It is intended to explore the strategic and evolutionary implications that emerge when the world consists entirely of prisoner's dilemma like interactions. If you are unfamiliar with the basic concepts of the prisoner's dilemma or the iterated prisoner's dilemma, please refer to the PD BASIC, PD TWO PERSON ITERATED and PD N-Person Iterated models found in the PRISONER'S DILEMMA suite.


## HOW IT WORKS

In the Iterated PD different strategies interact in different ways with each other. This makes it difficult to determine a single "best" strategy. One such approach to doing this is to create a world with multiple agents playing a variety of strategies in repeated prisoner's dilemma situations. The players win energy from each game, which they can use to reproduce. If a player has no energy it dies. The turtles with different strategies wander around randomly until they find another turtle to play with. (Note that each turtle remembers their last interaction with each other turtle. While some strategies don't make use of this information, other strategies do.)

Payoffs

When two turtles interact, they display their respective payoffs as labels.

Each turtle's payoff for each round will determined as follows:

                 | Partner's Action
      Turtle's   |
       Action    |   C       D
     ------------|-----------------
           C     |   3       0
     ------------|-----------------
           D     |   5       1
     ------------|-----------------
      (C = Cooperate, D = Defect)


## HOW TO USE IT

Buttons:

SETUP: Setup the world to begin playing the multi-person iterated prisoner's dilemma. The number of turtles and their strategies are determined by the slider values.

GO: Have the turtles walk around the world and interact.

GO ONCE: Same as GO except the turtles only take one step.

Sliders:

N-STRATEGY: Multiple sliders exist with the prefix N- then a strategy name (e.g., n-cooperate). Each of these determines how many turtles will be created that use the STRATEGY. Strategy descriptions are found below:

Strategies:

RANDOM - randomly cooperate or defect

COOPERATE - always cooperate

DEFECT - always defect

TIT-FOR-TAT - If an opponent cooperates on this interaction cooperate on the next interaction with them. If an opponent defects on this interaction, defect on the next interaction with them. Initially cooperate.

UNFORGIVING - Cooperate until an opponent defects once, then always defect in each interaction with them.

UNKNOWN - This strategy is included to help you try your own strategies. It currently defaults to Tit-for-Tat.

Plots:

AVERAGE-PAYOFF - The average payoff of each strategy in an interaction vs. the number of iterations. This is a good indicator of how well a strategy is doing relative to the maximum possible average of 5 points per interaction.

## THINGS TO NOTICE

Set all the number of player for each strategy to be equal in distribution.  For which strategy does the average-payoff seem to be highest?  Do you think this strategy is always the best to use or will there be situations where other strategy will yield a higher average-payoff?

Set the number of n-cooperate to be high, n-defects to be equivalent to that of n-cooperate, and all other players to be 0.  Which strategy will yield the higher average-payoff?

Set the number of n-tit-for-tat to be high, n-defects to be equivalent to that of n-tit-for-tat, and all other playerst to be 0.  Which strategy will yield the higher average-payoff?  What do you notice about the average-payoff for tit-for-tat players and defect players as the iterations increase?  Why do you suppose this change occurs?

Set the number n-tit-for-tat to be equal to the number of n-cooperate.  Set all other players to be 0.  Which strategy will yield the higher average-payoff?  Why do you suppose that one strategy will lead to higher or equal payoff?


## THINGS TO TRY

1.  Observe the results of running the model with a variety of populations and population sizes. For example, can you get cooperate's average payoff to be higher than defect's? Can you get Tit-for-Tat's average payoff higher than cooperate's? What do these experiments suggest about an optimal strategy?

2.  Currently the UNKNOWN strategy defaults to TIT-FOR-TAT. Modify the UNKOWN and UNKNOWN-HISTORY-UPDATE procedures to execute a strategy of your own creation. Test it in a variety of populations.  Analyze its strengths and weaknesses. Keep trying to improve it.

3.  Relate your observations from this model to real life events. Where might you find yourself in a similar situation? How might the knowledge obtained from the model influence your actions in such a situation? Why?

## EXTENDING THE MODEL

Complex strategies using lists of lists - The strategies defined here are relatively simple, some would even say naive.  Create a strategy that uses the PARTNER-HISTORY variable to store a list of history information pertaining to past interactions with each turtle.

Evolution - Create a version of this model that rewards successful strategies by allowing them to reproduce and punishes unsuccessful strategies by allowing them to die off.

Noise - Add noise that changes the action perceived from a partner with some probability, causing misperception.

Spatial Relations - Allow turtles to choose not to interact with a partner.  Allow turtles to choose to stay with a partner.

Environmental resources - include an environmental (patch) resource and incorporate it into the interactions.

## NETLOGO FEATURES

Note the use of the TO-REPORT primitive in the function CALC-SCORE to return a number

Note the use of lists and turtle ID's to keep a running history of interactions in the PARTNER-HISTORY turtle variable.

Note how agent sets that will be used repeatedly are stored when created and reused to increase speed.

## RELATED MODELS

PD Basic

PD Two Person Iterated

PD Basic Evolutionary

## HOW TO CITE

If you mention this model in an academic publication, we ask that you include these citations for the model itself and for the NetLogo software:  
- Wilensky, U. (2002).  NetLogo PD N-Person Iterated model.  http://ccl.northwestern.edu/netlogo/models/PDN-PersonIterated.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.  
- Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

In other publications, please use:  
- Copyright 2002 Uri Wilensky. All rights reserved. See http://ccl.northwestern.edu/netlogo/models/PDN-PersonIterated for terms of use.

## COPYRIGHT NOTICE

Copyright 2002 Uri Wilensky. All rights reserved.

Permission to use, modify or redistribute this model is hereby granted, provided that both of the following requirements are followed:  
a) this copyright notice is included.  
b) this model will not be redistributed for profit without permission from Uri Wilensky. Contact Uri Wilensky for appropriate licenses for redistribution for profit.

This model was created as part of the projects: PARTICIPATORY SIMULATIONS: NETWORK-BASED DESIGN FOR SYSTEMS LEARNING IN CLASSROOMS and/or INTEGRATED SIMULATION AND MODELING ENVIRONMENT. The project gratefully acknowledges the support of the National Science Foundation (REPP & ROLE programs) -- grant numbers REC #9814682 and REC-0126227.
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
NetLogo 5.1.0
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
