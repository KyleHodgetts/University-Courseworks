;;----------------------------------------------------------------------------
;; wumpus.nlogo
;;
;; A NetLogo version of (part of) the Russell & Norvig Wumpus World.
;;
;; Author:   Simon Parsons
;; Modified: October 11th
;; Version:  2.2
;;----------------------------------------------------------------------------

;;----------------------------------------------------------------------------
;; Breeds

;; We have two kinds of entity, wumpuses and agents.
breed [wumpuses wumpus]
breed [agents agent]

;;----------------------------------------------------------------------------
;; Variables
;;

;; we use a global variables to record how many golds we have collected on a given
;; run, how many steps have been taken, and what the score is.
globals [grabbed steps score]
;; patches have attributes --- they can be pits and they can be smelly, and either gold
;; or a wumpus (or both) can be on a patch.
patches-own [am-pit? am-breezy? am-smelly? am-gold? am-wumpus?]

;; here you can add state information to be used by move-with-state
agents-own []

;;----------------------------------------------------------------------------
;;
;; SIMULATOR STUFF
;;
;;----------------------------------------------------------------------------

;; go
;;
;; the main simulator loop. in a given tick we move agents and the wumpus, we
;; colour patches appropriately, we kill any agents that have wandered into pits,
;; and we decide whether we have reached the end.
to go
  move-everyone
  spot-wumpus
  spot-smelly
  check-death
  color-patches
  keep-score
  if stop-now? [stop]
  tick
end

;; move-everyone
;;
;; moving everyone means asking agents and wumpus to move.
to move-everyone
  ask agents [move-agent]
  ask wumpuses [move-wumpus]
end

;; check-death.
;;
;; agents die if they have entered a pit patch or are sharing a patch with a wumpus.
;; Wumpuses can navigate pits safely.
to check-death
  ask agents [if in-pit? [die]]
  ask agents [if at-wumpus? [die]]
end

;; keep-score
;;
;; update the score. positive points for collecting gold, negative points for moving.
to keep-score
  set score ((grabbed * 1000) - steps)
end

;; stop-now?
;;
;; conditions under which we halt. either at least one agent has survived until tick 500,
;; or all agents are dead, or the agents have recovered all the gold.
to-report stop-now?
  ifelse (ticks > 500) [show "DRAW" report true]
    [ifelse (count agents < 1) [show "You LOSE" report true]
      [ifelse (count patches with [am-gold?] < 1) [show "You WIN" report true] [report false]]]
end

;;----------------------------------------------------------------------------
;; Setup of the environment
;;
;; we make agents look like people and wumpuses look like monsters. we place agents
;; wumpuses, pits and gold randomly. then we colour patches appropriately so that
;; everything looks good before we "go".
to setup
  set-default-shape agents "person"
  set-default-shape wumpuses "monster"
  clear-all
  create-the-agents
  create-the-wumpus
  pick-pits
  pick-gold
  spot-breezy
  spot-wumpus
  spot-smelly
  color-patches
 reset-ticks
end

;; create-the-wumpus
;;
;; create one wumpus, put it in a random position, and color it so that it shows up
;; against the possible backgrounds.
to create-the-wumpus
  create-wumpuses 1 [ setxy random-xcor random-ycor set color grey]
end

;; create-the-agents

to create-the-agents
  create-agents 10 [ setxy random-xcor random-ycor ]
  ask agents [pick-heading]
end

;; pick-heading
;;
;; set agents up so that the
to pick-heading
  let direction random 4
  set direction direction * 90
  set heading direction
end

;; pick-pits
;;
;; based on the pits slider, randomly pick patches to be pits.
to pick-pits
  let number (2 * max-pxcor) * (2 * max-pxcor)
  ask patches [ifelse (random number < pits)
    [set am-pit? true]
    [set am-pit? false]]
end

;; spot-breezy
;;
;; have pits identify the breezy patches around them.
to spot-breezy
  ask patches [set am-breezy? false]
  ask patches [if (am-pit?) [ask neighbors [set am-breezy? true]]]
end

;; pick-gold
;;
;; as for pits, but now for gold
to pick-gold
  let number (2 * max-pxcor) * (2 * max-pxcor)
  ask patches [ifelse (random number < gold)
    [set am-gold? true]
    [set am-gold? false]]
end

;; spot-wumpus
;;
;; spot if the patch has the wumpus on it. Unlike pits and breeze and gold,
;; this is not a fixed property of the world, but depends on where the wumpus is.
to spot-wumpus
  ask patches [set am-wumpus? false]
  ask patch-set ([patch-here] of wumpuses) [set am-wumpus? true]
end

;; spot-smelly
;;
;; Have wumpuses identify the smelly patches around them.
to spot-smelly
  ask patches [set am-smelly? false]
  ask patches [if (am-wumpus?) [set am-smelly? true]]
  ask patches [if (am-wumpus?) [ask neighbors [set am-smelly? true]]]
end

;; color-patches
;;
;; patches are green by default, black if pits, blue if breezy, brown if smelly and
;; yellow if gold. patches can have multiple flags set, and only show the latest
;; color set (but the sensor functions are not confused by this). some of the colours
;; are only shown if the relevant switch is set.
to color-patches
  ask patches [set pcolor green]
  if visible-breeze? [ask patches [if (am-breezy?) [set pcolor blue]]]
  ask patches [if (am-gold?) [set pcolor yellow]]
  ask patches [if (am-pit?) [set pcolor black]]
  if visible-smell? [ask patches [if (am-smelly?) [set pcolor brown]]]
end

;; move-wumpus
;;
;; moves more or less randomly, if it moves at all.
to move-wumpus
  if wumpus-moves?
  [let angle ((random 360) - 180)
  right angle
  forward 1]
end

;;----------------------------------------------------------------------------
;;
;; sensor-like functions that are not accessible to the agents. both of these
;; are used by the simulator to determine if an agent should die.

;; in-pit?
;;
;; am I in a pit?
to-report in-pit?
  let answer false
  ask patch-here [if am-pit? [set answer true]]
  report answer
end

;; at-wumpus?
;;
to-report at-wumpus?
  let answer false
  ask patch-here [if am-wumpus? [set answer true]]
  report answer
end

;;----------------------------------------------------------------------------
;;
;; API
;;
;;----------------------------------------------------------------------------

;;----------------------------------------------------------------------------
;;
;; Sensor functions: how your agent will "see" the environment


;; breezy?
;;
;; am I in a breezy square?
to-report breezy?
  let answer false
  ask patch-here [if am-breezy? [set answer true]]
  report answer
end

;; smelly?
;;
;; am I in a smelly square?
to-report smelly?
  let answer false
  ask patch-here [if am-smelly? [set answer true]]
  report answer
end

;; glitters?
;;
;; am I in a square that glitters?
to-report glitters?
  let answer false
  ask patch-here [if am-gold? [set answer true]]
  report answer
end

;;----------------------------------------------------------------------------
;;
;; Action functions: how your agent will act in the environment. Every action
;; function has a cost.

;; left-turn
;;
;; turn to the left
to left-turn
  left 90
  set steps steps + 1
end

;; right-turn
;;
;; turn to the right
to right-turn
  right 90
  set steps steps + 1
end

;; go-forward
;;
;; take one step in the direction the agent is facing, and record the step.
to go-forward
  forward 1
  set steps steps + 1
end

;; grab-gold
;;
;; When an agent calls this, an attempt will be made to pick up gold. This only
;; succeeds when the agent is on a patch that holds gold.
to grab-gold
  if glitters? [set grabbed grabbed + 1]
  ask patch-here [set am-gold? false]
  set steps steps + 1
end

;;----------------------------------------------------------------------------
;;
;; Control program(s)
;;
;;----------------------------------------------------------------------------

;; move-agent
;;
;; top level move function that is called every time around the main go loop. Picks
;; between random, rule-based and with-state movement
to move-agent
  ifelse agent-type = "random"
  [move-random]
  [
  ifelse agent-type = "rule-based"
  [move-rule-based]
  [
  if agent-type = "with-state"
  [move-with-state]]]
end

;; move-random
;;
;; pick between no turn, turn left and turn right, then move forward. not a good strategy
;; in a dangerous dungeon.
to move-random
  let move random 3
  if (move = 0)[] ; no turn
  if (move = 1)[left-turn]
  if (move = 2)[right-turn]
  go-forward
  if glitters? [grab-gold]
end

;; move-rule-based
;;
;; what you have to write
to move-rule-based
  ; Always ensure that any gold is picked up
  if glitters? [grab-gold]
  ; Will eventually turn away from pit and be out of breeze
  ifelse breezy? [right-turn]
  [
    ; Turn away from the wumpus in case he moves towards you.
    ifelse smelly? [right-turn right-turn][
      ; Neither breezy nor smelly
      ; Move randomly. May be facing wall
      let move random 3
      if (move = 0)[] ; no turn
      if (move = 1)[left-turn]
      if (move = 2)[right-turn]
    ]
  ]
  go-forward ; Attempt to move
end

;; move-with-state
;;
;; what you have to write
to move-with-state
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
560
381
8
8
20.0
1
10
1
1
1
0
0
0
1
-8
8
-8
8
1
1
1
ticks
30.0

BUTTON
19
10
92
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
127
10
190
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
19
51
191
84
pits
pits
0
20
6
1
1
NIL
HORIZONTAL

SLIDER
19
89
191
122
gold
gold
0
10
5
1
1
NIL
HORIZONTAL

CHOOSER
16
256
193
301
agent-type
agent-type
"random" "rule-based" "with-state"
1

SWITCH
19
129
192
162
wumpus-moves?
wumpus-moves?
0
1
-1000

SWITCH
17
167
192
200
visible-breeze?
visible-breeze?
0
1
-1000

SWITCH
16
208
191
241
visible-smell?
visible-smell?
0
1
-1000

MONITOR
573
13
671
58
agents
count agents
17
1
11

MONITOR
573
69
671
114
score
score
17
1
11

TEXTBOX
25
325
175
343
Wumpus World (version 2)
11
0.0
1

@#$#@#$#@
## WHAT IS IT?

This is an implementation of the Russell and Norvig "Wumpus World", intended as a vehicle for exploring some different approaches to agent design.

The environment is a dungeon. In it lurks the Wumpus, an evil smelly creature which will try to eat anyone who enters the dungeon. The dungeon contains pits (they appear as black squares). If an agent falls into a pit, it dies instantly. But the dungeon also contains gold (yellow squares) and picking up goal scores points.

The aim of the Wumpus World is for you to program a set of 10 agents which will enter the dungeon and try to retrieve all the gold while avoiding falling into pits and being eaten by the Wumpus. You do that by programming the functions "move-rule-based" and move-with-state". These will then be used to control all the agents.

Note that, unlike the Russell and Norvig version, the Wumpus in this World can move.

## HOW IT WORKS

Pits and gold are distributed randomly. The Wumpus and the agents move randomly. For now, that is it.

## HOW TO USE IT

Like most NetLogo models, the main controls are "setup", which performs a setup of all the random elements of the model (like positions of agents, Wumpus, pits and gold) and "go" which starts the simulation.

The simulation will run until one of three things happens:

1. All the agents die, either because the Wumpus eats them, or because they fall into pits. In this case you lose.

2. All the gold is grabbed. In this case you win.

3. The simulation reaches 500 ticks. In this case it is a draw.

When the simulation finishes, a message saying whether you won, lost or drew will be printed in the Command Center.

There are some additional controls.

The sliders "pits" and "gold" control how many pits and gold are generated by "setup". Because the selection of patches is random, you won't be able to use these sliders to precisely control the numbers, but a larger value for "pits" will mean, on average, a larger number of pits and so on.

The switch "wumpus-mobile?" controls whether the Wumpus moves or not.

The switches "visible-breeze?" and "visible-smell?" control whether those elements (which the agent can detect) are visible. I found it helpful to be able to see them when I was debugging, but annoying to see them all the time.

The selector "agent-type" picks between the default random agents, and agents which use the two movement functions that you will write.

## THINGS TO TRY

Run the program with different numbers of pits and gold, and with the Wumpus moving and stationary. Is there a combination where the agents win most of the time?

## 3.0 & 3.1 Evaluating the default approach
### Initial Run Results
![Initial Run](file:initialrun.png)
![Initial Analysis](file:initialanalysis.png)

The agent won 1/5 of the time.

## 3.2 & 3.3 Condition / Action Controller
### Rule Run Results
![Rule Run](file:rulerun.png)
![Rule Analysis](file:ruleanalysis.png)

The agent won 4/5 of the time, a substantial improvement on the previous run.
When the agent won in the previous run, it did so in a much less amount of ticks to the current run. I attribute this to the rule-based agent attempting to avoid pits and the Wumpus whilst looking for the gold.

## 3.4 & 3.5 State Controller
### State Run Results

## EXTENDING THE MODEL

Your job is to write new controllers for "move-rule-based" and "move-with-state". Full details are on the lab sheet.

## CREDITS AND REFERENCES

The Wumpus World is taken from:

Artificial Intelligence: A Modern Approach, 3rd Edition, Stuart Russell and Peter Norvig, Pearson ISBN:978-1292153964 (paperback), 978-0136042594 (hardcover).
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

monster
false
0
Polygon -7500403 true true 75 150 90 195 210 195 225 150 255 120 255 45 180 0 120 0 45 45 45 120
Circle -16777216 true false 165 60 60
Circle -16777216 true false 75 60 60
Polygon -7500403 true true 225 150 285 195 285 285 255 300 255 210 180 165
Polygon -7500403 true true 75 150 15 195 15 285 45 300 45 210 120 165
Polygon -7500403 true true 210 210 225 285 195 285 165 165
Polygon -7500403 true true 90 210 75 285 105 285 135 165
Rectangle -7500403 true true 135 165 165 270

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

robot2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Rectangle -7500403 true true 150 30 150 135
Rectangle -7500403 true true 135 30 160 138

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
NetLogo 5.3.1
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
