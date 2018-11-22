turtles-own
[ opinion 
  new-opinion
  left-cluster]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to setup
  clear-all
   
  ;;call procedures that initialize the system
  setup-nodes   
  setup-network  
  ask patches [ set pcolor white ]   ;; get a white background
  
  ;;initialize the opinions and provide statistics
  ask turtles [set opinion random-float 1
               update-look-of-turtle]
  
  ;;graphical output   
  my-update-plots     
  show-influence-links
  
  reset-ticks
end ;;to setup

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to setup-nodes  ;;create two groups of agents
    set-default-shape turtles "face happy"  
    crt N
      [ set size 2.5
        set label who
        set label-color  black ]
end ;;to setup-nodes

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to setup-network   
  ;;1st create the two segments
  layout-circle turtles with [who <  (N / 2)]   15
  layout-circle turtles with [who >= (N / 2)]   15
  ask turtles[
        if who <  (N / 2) [set xcor  xcor - 20 ]
        if who >= (N / 2) [set xcor  xcor + 20 ] ]
  
  ;;2nd connect all pairs of agents who are member of the same segment
  ask turtles [ 
              ifelse (who <  (N / 2))  [create-links-with other turtles with [   ((who <   (N / 2))) and  (not link-neighbor? myself)  ]]
                                                     [create-links-with other turtles with [   ((who >=  (N / 2))) and  (not link-neighbor? myself)  ]]   ]
                                                     
  ;;3rd connect the two segment with one additional link (choose closest turtles for graphical reasons)
  let linkend max-one-of turtles with [(who <   (N / 2))] [xcor]                          ;;reports an agent set containing the most rightist turtle of the left component
  ask min-one-of turtles with [(who >=   (N / 2))] [xcor]   [create-link-with linkend ]

  
  ;;4th rewire if wanted
  if R > 0 [Maslov_Sneppen_rewiring]
end ;;to setup-network

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to engine
  ask turtles 
   [set new-opinion (opinion + sum [opinion] of link-neighbors with [ abs(opinion - ([opinion] of myself)) <= BC-level  ]) / (1 + count link-neighbors with [ abs(opinion - ([opinion] of myself)) <= BC-level  ])   ]
  ask turtles 
  [set opinion new-opinion  
   update-look-of-turtle]

  ;;graphical output   
  my-update-plots
  show-influence-links
  
  tick
  if stop-ticking? [stop]
end ; run


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to show-influence-links 
  ask links with [abs( ([opinion] of end1) - ([opinion] of end2)) >  BC-level]  [ set color red]
  ask links with [abs( ([opinion] of end1) - ([opinion] of end2)) <= BC-level]  [ set color black]
  ask links with [color = black and (abs( ([opinion] of end1) - ([opinion] of end2)) < (10 ^ -10))] [set color green]
end ; to show-influence-links

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to my-update-plots
  set-current-plot "opinion distribution"
  set-histogram-num-bars 100
  histogram [opinion] of turtles   
    
  set-current-plot "opinion variance"
  plot (variance [opinion] of turtles)

  set-current-plot "Number of clusters"
  plot number-of-clusters
  
  set-current-plot "opinion range"
  plot opinion-range
  
end ; to update-plots  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to update-look-of-turtle
  ;set size (opinion * 10)
  set color scale-color red opinion 0 1
end ; update-look-of-turtle

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to-report stop-ticking?    ;call show-influence-links before this procedure to update link color
  ifelse (count links) = (count links with [color = red]) + (count links with [color = green])     [report true] [report false]
end ;to stop-ticking?
                                                          
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to Maslov_Sneppen_rewiring
 let A-who 99999
 let B-who 99999
 let C-who 99999
 let D-who 99999
 let successful 0
   
 while [successful < R]
  [;;first step: pick two pairs that might be rewired 
    ask one-of turtles 
            [set A-who who
             ask one-of link-neighbors [set B-who who]    ]                     
    ask one-of turtles 
            [set C-who who
            ask one-of link-neighbors  [set D-who who]    ]
              
   ;;second step: rewire if there aren't links already
    if ((A-who != D-who) and  (B-who != C-who) and  (A-who != C-who) and  (B-who != D-who)    and not (is-link? link A-who D-who) and not (is-link? link B-who C-who)  )
      [ask turtle A-who [ ask link-with turtle B-who [ die ] ] 
       ask turtle A-who [ create-link-with turtle D-who ]
       ask turtle C-who [ ask link-with turtle D-who [ die ] ] 
       ask turtle B-who [ create-link-with turtle C-who ]
       set successful successful + 1
      ]
  ] ;;while
end ;;to Maslov_Sneppen_rewiring

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to-report number-of-clusters
  let opinion-vector []
  ask turtles [ set opinion-vector fput (precision opinion 9) opinion-vector]
  set opinion-vector remove-duplicates opinion-vector
  report length opinion-vector
end; to report number-of-clusters

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to-report opinion-range
  report (max [opinion] of turtles ) - (min [opinion] of turtles)
end; to report number-of-clusters
@#$#@#$#@
GRAPHICS-WINDOW
498
10
1293
632
40
30
9.7
1
10
1
1
1
0
0
0
1
-40
40
-30
30
1
1
1
ticks
30.0

BUTTON
146
23
241
106
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

SLIDER
148
180
343
213
N
N
10
200
50
5
1
NIL
HORIZONTAL

TEXTBOX
144
136
405
167
Model parameters
24
0.0
1

PLOT
41
384
236
534
opinion distribution
NIL
abs. freq.
0.0
1.0
0.0
10.0
true
false
"" ""
PENS
"default" 0.01 1 -16777216 true "" ""

SLIDER
146
235
342
268
BC-level
BC-level
0
1
0.3
0.02
1
NIL
HORIZONTAL

BUTTON
254
23
349
105
run
engine
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
245
542
444
692
Opinion variance
time
NIL
0.0
10.0
0.0
0.1
true
false
"" ""
PENS
"opinion_variance" 1.0 0 -2674135 true "" ""

SLIDER
145
293
339
326
R
R
0
1000
2
1
1
NIL
HORIZONTAL

PLOT
41
542
236
692
Number of clusters
time
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" ""

PLOT
245
384
445
534
opinion range
opinion
range
0.0
1.0
0.0
1.0
true
false
"" ""
PENS
"opinion_range" 1.0 0 -16777216 true "" ""

TEXTBOX
147
346
368
379
Output measures
24
0.0
1

TEXTBOX
156
165
306
183
Number of agents
11
0.0
1

TEXTBOX
155
220
477
238
Degree of homophily (high values imply weak homophily)
11
0.0
1

TEXTBOX
156
276
306
294
Network structure\n
11
0.0
1

@#$#@#$#@
## WHAT IS IT?

Based on the famous bounded-confidence model by Hegselmann and Krause (2002), this program allows you to develop hypotheses about the effects of homophily and network structure on the outcomes of social-influence processes in networks. In particular, you can identify the conditions under which the influence process results in perfect opinion homogeneity (consensus) or opinion diversity (clustering).

Homophily, the first independent variable, models that individuals tend to interact only with others who hold similar opinions. The corresponding "BC-level" slider manipulates how similar two agents need to be to have impact on each others' opinions.

The structure of the network is the second independent variable. The R-slider manipulates the degree to which the network is clustered. That is, if R is set to zero, the network consists of two network clusters where all members of a cluster are connected to each other. There is, however, only a single link between the two clusters. Thus, this network is connected but maximally clustered. When R adopts higher values, the program randomly rewires ties R times, which leads to more links between the network clusters. We implemented the Maslov-Sneppen-rewiring algorithm (2002), which only manipulates network structure and keeps the number of network links in the populations as well as the number of connections of each agent constant.


## HOW IT WORKS
Each agent is described by a variable that represents her opinion. Opinions can adopt any value between zero and one. On the interface, the color (red shades) of the agents depicts their opinion.

In addition, agents are connected to other members of the population by network links. A network link represents that the connected agents can influence each other. Links are fixed. However, whether or not the opinion of a connected agent is influential at a given point in time depends on the similarity between the agents. On the interface, a green link shows that the two agents hold identical opinions. Black links depicts that the agents hold different opinions, but the opinion difference is not too big. If the opinion difference exceeds the threshold defined by the "BC-level " slider, however, links turn red. This shows that the two agents do not exert influence on each other’s opinions, although they are connected.

Initially, agents are assigned a random opinion value, which is drawn from a uniform distribution. At each tick, the opinions of all agents are updated. The updated opinion is the average of the opinions of the networks contacts that are not too different.

The opinion updating continues until dynamics reach equilibrium. There a two possible equilibria. First, dynamics settle when all agents hold identical opinions (consensus). Second, equilibrium is reached when agents have formed opinion clusters where all members of a cluster hold identical opinions but the opinion differences between members of different clusters exceed the "bounded-confidence" threshold.

## HOW TO USE IT
On the interface, select the size of the population, using the N-slider, and how strong homophily is, using the BC-level slider. For instance, when you set the BC-level slider to a value of zero, agents are influenced only by those network neighbors that are perfectly similar. A BC-level of 1, on the other hand, assumes that agents are influenced by all network neighbors. A value of 0.5 would imply that agents are influenced only by those network neighbors that hold opinions that differ not more than 0.5 from the focal agent's opinion.

Finally, select a network structure with the R-slider. When you click the setup button, the system is initialized. Next, click the run button and the program will update agents' opinions until equilibrium is reached

On the interface, there are four output graphs, which visualize the dynamics of the model. First, there is a histogram of the opinion distribution in the population. Second, a graph shows the development of the range of the opinion distribution (max[opinion] - min[opinion]). Third, a graph depicts the development of the number of opinion clusters. An opinion cluster is a set of agents with identical opinions. Fourth, a graph reports the development of the variance of the opinion distribution.

In addition, we implemented a simple simulation experiment in the BehaviorSpace tool of NetLogo. With this experiment, you can study populations of 100 agents and explore how influence dynamics are affected by the structure of the network and the degree of homophily. The experiment will conduct 100 independent simulation runs per experimental condition.

## THINGS TO NOTICE
We implemented the Maslov-Sneppen rewiring algorithm.

## THINGS TO TRY
We suggest that you use the model to study how network structure and homophily strength affect the degree of opinion diversity in equilibrium. In addition, there are interesting effects of the two independent variables on the number of ticks needed to reach equilibrium.

## EXTENDING THE MODEL
Three simple extensions might be interesting. First, you may want to study more diverse network structures (see e.g. the examples in the NetLogo model library). Second, you may want to relax the assumption that all agents have the same degree of homophily. In other words, one might include variation in the BC-level of the agents. Finally, it would be interesting to study the robustness of the model predictions to the effects of randomness. The work by Mäs et al. (2010) and Pineda et al. (2009) has shown that the predictions of the Bounded-Confidence model can change in various unexpected ways when noise is included.


## RELATED MODELS
The model is similar to Axelrod's model of cultural dissemination, which has been implemented in NetLogo
(see http://ccl.northwestern.edu/netlogo/models/community/cultura
and http://ccl.northwestern.edu/netlogo/models/community/AxelrodV2)

The Bounded-Confidence model and many very interesting extensions have been implemented by Jan Lorenz here: http://ccl.northwestern.edu/netlogo/models/community/bc

## CREDITS AND REFERENCES
The program was written by Michael Mäs and Andreas Flache.

Corresponding author:
Michael Mäs
ETH Zürich
Clausiussstrasse 37
8092 Zürich

e-mail: mmaes@ethz.ch<mailto:mmaes@ethz.ch>
www.maes-sociology.eu<http://www.maes-sociology.eu>


References


Hegselmann, Rainer and Ulrich Krause. 2002. "Opinion Dynamics and Bounded Confidence Models, Analysis, and Simulation." Journal of Artificial Societies and Social Simulation 5 (3).

Mäs, Michael, Andreas Flache, and Dirk Helbing. 2010. "Individualization as Driving Force of Clustering Phenomena in Humans." PLoS Computational Biology 6 (10):e1000959.

Maslov, S. and K. Sneppen. 2002. "Specificity and Stability in Topology of Protein Networks." Science 296 (5569):910-913.

Pineda, M., R. Toral, and E. Hernandez-Garcıa. 2009. "Noisy Continuous-Opinion Dynamics." Journal of Statistical Mechanics P08001.

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
NetLogo 5.0.3
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>engine</go>
    <metric>number-of-clusters</metric>
    <metric>opinion-range</metric>
    <enumeratedValueSet variable="MS_rewiring_iterations">
      <value value="0"/>
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
      <value value="6"/>
      <value value="7"/>
      <value value="8"/>
      <value value="9"/>
      <value value="10"/>
      <value value="15"/>
      <value value="20"/>
      <value value="25"/>
      <value value="30"/>
      <value value="40"/>
      <value value="50"/>
      <value value="60"/>
      <value value="70"/>
      <value value="80"/>
      <value value="90"/>
      <value value="100"/>
      <value value="1000"/>
    </enumeratedValueSet>
    <steppedValueSet variable="bounded-confidence" first="0" step="0.1" last="1"/>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="100"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
