extensions [nw]

;; Innovators is a better term for these then 'turtles'
breed [innovators innovator]

innovators-own [idea c-progress t-elapsed n-innovations n-failures success-rate centrality]

globals [total-innovations rate  max-innovations max-centrality
         average-innovation-rate selected delete-clicked? no-fail]


to setup
  ca
  ;; for debuging only
  set no-fail false

  set selected nobody

  set delete-clicked? false
  set max-innovations 1 ;; to avoid issues with plot

   ;; create agents on network
  (ifelse network-type = "random" [
    nw:generate-random innovators links N-agents prob ]
  network-type  = "watts-strogatz" [
    nw:generate-watts-strogatz innovators links N-agents neighborhood-size rewire-prob ]
  network-type = "preferential-attachment" [
    nw:generate-preferential-attachment innovators links N-agents min-degree
    ]
  [ stop ])

  ;; set up innovators
  ask innovators [
    reset-innovator
    random-idea
    set centrality nw:betweenness-centrality
    color-innovator
  ]
  set max-centrality max [centrality] of innovators


   ;; seperate spacially
  ask innovators [
    ifelse random-layout? [setxy random-xcor random-ycor]
      [ repeat 30 [ layout-spring innovators links 0.5 2 2 ] ]
  ]

  reset-ticks

end


;; GO

to go

  let prev total-innovations
  ask innovators  [
    set t-elapsed t-elapsed + 1
    let other-innovator one-of other innovators

    if (collaborate-prob other-innovator) > random-float 1 [
      set c-progress c-progress + 1 ;; make progress toward invention
      set idea combine-ideas idea [idea] of other-innovator
     ]
    if-else c-progress = succ-thresh [
      set n-innovations n-innovations + 1   ;; successful innovation!
      set total-innovations total-innovations + 1 ;; seperately track
      reset-innovator                       ;; start again
      ] [

      if not no-fail [
        if t-elapsed > T-max [        ;; time ran out, investors lost patience
          reset-innovator
          mutate-idea
          set n-failures n-failures + 1
        ]
      ]
    ]
  let total-attempts n-innovations + n-failures
  if-else total-attempts > 0 [
      set success-rate n-innovations / total-attempts
      ]
      [
      set success-rate 0
       ]
  ]
  set rate total-innovations - prev
  update-stats
  ask innovators [color-innovator]
  select-innovator
  if delete-clicked? [delete-selected]
  tick
end


;; Rreset the statistics on all innovators
to reset-stats
ask innovators [
    set n-innovations 0
    set n-failures 0
  ]
  set total-innovations 0
end



;; consider also log transform
to color-innovator
    (ifelse color-by = "innovation count"
      [set color scale-color blue n-innovations 0 max-innovations ]

      color-by = "idea"
      [
        if n-idea = 0 [stop]
        let bit-string-to-int reduce [ [result bit] -> result * 2 + bit ] idea
        let hue (bit-string-to-int mod 360)  ;; Map the integer to a hue value between 0 and 360
        set color hsb hue 100 100  ;; Set color using the HSB model with full saturation and brightness
      ]

      color-by = "centrality"
      [set color scale-color blue centrality 0 max-centrality]
      [])
end

to reset-innovator
  set t-elapsed 0
  set c-progress 0
end


;; INNOVATION
;; TODO make this representation more efficient, use matrix exentsion?

to random-idea
  set idea n-values n-idea [random 2]
end

to-report invert-idea [idea1]
  report map [i -> (1 - i)] idea1
end


;; not (a xor b) is same as (a + b) mod 2
to-report xor-idea [idea1 idea2]
  report (map [ [a b] -> (a + b) mod 2  ] idea1 idea2)
end




to-report hamming-d [idea1 idea2]
  report (sum   (xor-idea idea1 idea2) )
end

to-report compare-idea [idea1 idea2]
   if-else n-idea > 0 [
    report 1 - ((hamming-d idea1 idea2) / n-idea)
  ][
    report 1
  ]
end

;; attempt collaboration
to-report collaborate-prob [other-innovator]
  let d nw:distance-to other-innovator
  let simularity compare-idea idea ([idea] of other-innovator)
  report ifelse-value d = false [0] [ (p ^ d) * simularity]
end

;; combine idea with collaborator using 'uniform crossover'
to-report combine-ideas [idea1 idea2]
  let new-idea (map [ [a b] -> ifelse-value (random 2 = 0) [a] [b] ] idea1 idea2)
  report new-idea
end

;; random mutation
to mutate-idea
  let new-idea map [i -> ifelse-value (random-float 1 < mutation-rate) [(1 - i)] [i]] idea
  set idea new-idea
end




;; for testing purposes only

to test-compare
  let idea1 n-values n-idea [0]
  if ( compare-idea idea1 idea1  != 1) [show "compare-idea failed test 1"]

  let idea2 n-values n-idea [0]
  set idea2 replace-item 0 idea2 1
  if ( compare-idea idea1 idea2 != (n-idea - 1) / n-idea ) [show "compare-idea failed test 2"]

end

to update-stats
  set max-innovations max [n-innovations] of innovators

  ;; exponential smoother.
  set average-innovation-rate average-innovation-rate * (1 - 1 / n-accum)
  set average-innovation-rate average-innovation-rate + rate / n-accum
end





to delete-selected
  set delete-clicked? false
  if selected != nobody
  [ask selected [die]
   ask innovators [
      set centrality nw:betweenness-centrality
    ]
   set max-centrality max [centrality] of innovators
  ]
end


to select-innovator

  if mouse-down? [
    ; pick the closet turtle
    set selected min-one-of turtles [distancexy mouse-xcor mouse-ycor]
    ; check whether or not it's close enough
    ifelse [distancexy mouse-xcor mouse-ycor] of selected > 1 [
      set selected nobody ; if not, don't select it
      reset-perspective
    ][
      watch selected ; if it is, go ahead and `watch` it
    ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
247
79
684
517
-1
-1
13.0
1
10
1
1
1
0
0
0
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

SLIDER
25
20
197
53
N-Agents
N-Agents
0
250
100.0
1
1
NIL
HORIZONTAL

BUTTON
42
191
105
224
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
124
191
187
224
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
25
390
197
423
succ-thresh
succ-thresh
1
50
2.0
1
1
NIL
HORIZONTAL

SLIDER
1077
465
1249
498
prob
prob
0
1
0.09
.01
1
NIL
HORIZONTAL

CHOOSER
910
375
1091
420
network-type
network-type
"random" "watts-strogatz" "preferential-attachment"
1

SLIDER
700
443
872
476
neighborhood-size
neighborhood-size
0
10
3.0
1
1
NIL
HORIZONTAL

TEXTBOX
700
390
938
418
Parameters for network generation
13
34.0
1

SLIDER
888
463
1061
496
min-degree
min-degree
1
10
2.0
1
1
NIL
HORIZONTAL

TEXTBOX
1080
425
1230
443
Random
11
0.0
1

TEXTBOX
705
425
855
443
Watts Strogatz
11
0.0
1

SLIDER
701
483
873
516
rewire-prob
rewire-prob
0
1
0.2
.05
1
NIL
HORIZONTAL

TEXTBOX
895
425
1045
443
Preferential Attachment
11
0.0
1

SWITCH
37
96
179
129
random-layout?
random-layout?
1
1
-1000

SLIDER
25
320
197
353
p
p
0
1
0.51
.01
1
NIL
HORIZONTAL

SLIDER
23
62
195
95
n-idea
n-idea
0
32
32.0
1
1
NIL
HORIZONTAL

SLIDER
26
356
198
389
T-max
T-max
0
100
25.0
1
1
NIL
HORIZONTAL

PLOT
705
80
905
230
InnovationRate
Mean innovation rate
ticks
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot average-innovation-rate"

MONITOR
710
296
808
341
avg success rate
mean [success-rate] of innovators
6
1
11

SLIDER
20
430
192
463
mutation-rate
mutation-rate
0
0.5
0.02
.01
1
NIL
HORIZONTAL

MONITOR
709
243
840
288
Mean innovation rate
average-innovation-rate
7
1
11

CHOOSER
261
27
476
72
color-by
color-by
"innovation count" "idea" "centrality"
1

BUTTON
490
35
662
68
delete selected innovator
set delete-clicked? true
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
919
259
1263
304
NIL
[idea] of selected
17
1
11

PLOT
942
55
1225
244
Innovations vs Centrality
Centrality
Normalized Innovations
0.0
10.0
0.0
10.0
true
false
"" "clear-plot\nset-plot-y-range 0 1"
PENS
"default" 1.0 2 -16777216 true "" "ask innovators [plotxy centrality (n-innovations / max-innovations)]"

SLIDER
800
35
927
68
n-accum
n-accum
1
500
50.0
10
1
NIL
HORIZONTAL

BUTTON
71
237
164
270
NIL
reset-stats
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
695
25
800
70
This sets time scale for exponential averaging
11
0.0
1

@#$#@#$#@
## WHAT IS IT? (Scope)

The phenomenon being modeled here is the effect of collaboration on innovation. The Agents in this model are *Innovators* that try to find others to join forces with. If the they find enough collaborators soon enough, they succesfully 'innovate'.   Otherwise they fail.   In this system 'fitness' is emergent: innovators are more successful if their ideas are similar to nearby innovators, since the probability of collaboration depends on having similar ideas.

The idea is to examine:
- How communication 'ease' effects overall rate of innovation
- How network structure effects overall rate of innovation
- How network centrality measures effect individual rate of innovation
  
## HOW IT WORKS

### Agents and properties

The `N-agents` in the model are *innovators* that live on a (user configurable) network environment connected by links to other innovators. The links have no properties in this model.

Innovators have three key properties:

- `idea` which is represented by a bit vector of length `n-idea`
- `t-elapsed` is how many time steps have elapsed during this innovation attempt.
- `c-progress` which is the count of successful collaborations during this attempt.

For completeness, the other agent properties, which are used for capturing statistics, are listed here:
 
- `n-innovations` : total number of innovations for this agent
- `n-failures` : total number of failed attempts
- `centrality` : cached value of the betweennesss centrality of the agent.
- `success-rate` : cached value of n-innovatoins/(n-innovations + n-failures)  

### Setup:

During setup:

* Global variables are initialized

* *Innovators* are created on the selected network type

* *Innovators* are initialized and given their inital random idea, as well as computing their centrality on the network

* *Innovators* are positioned either randomly or in a spring layout




### Each time step (GO):

- For each innovator:
    - Increment `t-elapsed`

    - Each *innovator* selects another innovator at random and attempts to collaborate with them. The probability of collaboration is `(p ^ d) * simularity`, where `d` is the (shortest) distance on the network,  `p` is the user configurable probability per hop, and `simularity` is computed as `1 - hamming-d/n-bits`.   Here `hamming-d` refers to the Hamming distance between the 2 ideas, which is the number of bits you would have to flip to make them the same.

     - On a success:
         - Increment `c-progress` for that innovator
         - The innovator combines its `idea` with that of the collaborator using uniform crossover (choose abit at random from the two ideas).   This brings their ideas closer, increasing the probability of a successful collaboration between these agents in the future. 
         - If `c-progress` is equal to `succ-thresh` then we count that as a successful innovation and increment `total-innovations` and the innovator's `n-innovations`. We also reset the  `t-elapsed` and `c-progress` counters to prepare for the next attempt.

    - If this was not a successful innovation we check to see if `t-elapsed` > `T-max` and if so, we reset the counters, mutate the innovators idea, and increment `n-failures` for that innovator.  The mutation is random where each bit flipped with probability `mutation-rate`. 

- We then wrap up by computing statistics and recoloring the innovators.


## HOW TO USE IT (Inputs and Outputs)


### Model configuration

At the top left are the primary pre-setup configuration variables:

- `N-agents` : The number of innovators in the model
- `n-idea` : the size of the idea bit vector
- `random-layout?` : If no, then a spring layout is used. Sometimes I prefered a random layout, and this allows this change (prior to setup). 

In addtion, the network type can be changed as well as the parameters for those network types, in the lower right.  For details see the documentation for the `nw` extension. Three types of networks are included:

- Random,  which is described by a single parameter, the probability of links.

- Watts Strogatz, which is described by two parameters: neighborhood-size which describes the initial number of nodes connected on each side and rewire-prob which describes the probability of rewiring a connection.

- Preferential Attachment, which has a single parameter, min-degree which is the number of links each new node has when it first joins the network

### Innovation model paramaters

- `p`  probability per hop of a 'potential' collaboration

- `succ-thres` The number of successful collaborations an innovator needs to collect before a successful innovation can be made.
 
- `T-max` The maximum number of steps that are an agent can take to reach `succ-thres`.

-  `mutation-rate` : The probabilty for each bit of a mutation (flip) after a failure to innovate.

### Other controls

- `reset-stats` button resets all statistics. 
- `color-by` allows you to chose how you want to color the innovators:
    - `idea`  - the bitvector is mapped to an integer, rescaled and turned into a hue
    - `centrality` - brighter innovators have a higher centrality
    - `innovation rate` - brighter innovators have a higher rate of innovation
- `n-accum` this sets the time constant (in steps) for exponential averaging that is used for the displayed innovation rate. 


### Outputs


The agents are displayed in the center on a 2-d display, colored by idea, centrality or innovation rate as discussed above.

The innovation rate for the system as a whole is displayed both as a graph and as a monitor output.  This is obtained by computing the difference between the total innovations from one time step to another.  This would be very noisy so the displayed values are averaged using an exponential smoother. (see the function `update-stats`) The amout of smoothing is controled by `n-accum`

Below the innovation rate is displayed the average success rate of all the agents. This is average of `n-innovations / (n-innovations + n-failures)` accross all the innovators. 

In the upper right is a scatter plot of the innovation rate (normalized by dividing by the maximum innovation rate) vs centrality.   

Below this is a monitor showing the`idea` of the selected innovator (if any).

### Selecting innovators 

While the model is running you can click on an innovator to select it. When you do this you can see the `idea` of that particular innovator in the display.  

You can also click `delete selected innovator` to remove this innovator (kill it).


### Other usage notes


I find things are more interesting if you adjust the paraemeters to have about 70% average success rate. Note that the average success rate is computed over the entire run. Use 'reset-stats' to get a fresh computation.

Note that if you set the idea size to 0, then only the network distance will determine innovation success.


## THINGS TO TRY

- Start with the default parameters.  Try the different coloring schemes. Note that central innovators are able to innovate more rapidly. This can also be seen in the scatter plot in the upper right.  This is as expected, which helps verify the model. 

- Adjust p and observe the change in innovation rate. This could represent, in the real world, the impact of making it more difficult to communicate with potential collaborators.  

- Observe the effect of network structure.  

- Observe the effect of changing the mutation rate. Remember this is used by an innovator that fails to innovate before `t-max`. Notice that the fastest innovation happens with no mutation. In that case the network settles down to everyone having the same idea. This is something that should be addressed in a future model (see below).

- Observe the effect of changing the success / failure criteria. (`t-max` and `succ-thresh`)

-  Try selecting and deleting important (high centrality) nodes. Do you see an appreciable effect? I only found an appreciable effect with a network generated by preferential attachment. This is probably best explored by running multiple sims using BehaviorSpace.

- There is also a regime where the 'idea' will remain stable for a while and then jump to another stable state. Color by 'idea' to see this effect.  Try setting p so that the observed success probability is close to but not 1.  If you start with the default settings, p ~ 0.65 seems to exhibit this behavior. This punctuated equilibrium could represent an idea being popular for a while and then a new idea taking over.


## EXTENDING THE MODEL

Some ideas for exentions:

* When agents are killed, replace them with a new agent. Consider how to connect it to the network. One option is to connect them preferentially to the more successful agents.

* Add new connections between successful collaborators.

* Currently only the active turtle has its idea modified by the collaboration, perhaps both should.

* Consider other network centrality measures.
 
* For high 'success-rate' or zero mutation rate the model settles down into a (potentially punctuated) equilibrium where the agents all have the same 'idea' and yet innovation continues. Furthermore, everyone having the same idea produces the highest innovation, as then the probability of succsessful collaboration highest.  However, we would expect that continuing to improve on the same idea should have diminishing returns. Some ideas on how to address this in future models:  

    * Maintain a list of ideas that were successfully innovated and prevent them from being selected again.

    * Have an external (e.g. NK) fitness landscape that is used to judge an ideas success. You still need to collaborate, but also ideas need to be 'good'. In this model we would also want previously exploited ideas to have a lower fitness, perhaps the fitness landscape changes dynamically as innovations are successful.  


 
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
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

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

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="social-influence-experiment" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>count turtles with [adopted?]</metric>
    <metric>count regulars with [adopted?]</metric>
    <metric>count influencers with [adopted?]</metric>
    <enumeratedValueSet variable="N_Agents">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="influencer-weight">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-layout?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="WS-max">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="prob">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-influential">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-degree">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;random&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rewire-prob">
      <value value="0.15"/>
    </enumeratedValueSet>
    <steppedValueSet variable="social-influence" first="0.1" step="0.1" last="1"/>
    <enumeratedValueSet variable="broadcast-influence">
      <value value="0.01"/>
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
1
@#$#@#$#@
