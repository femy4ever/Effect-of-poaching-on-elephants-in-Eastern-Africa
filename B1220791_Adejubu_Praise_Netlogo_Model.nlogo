; Begin code

globals [
  elephants-killed-by-poachers         ; counter to keep track of the number of elephants killed by poachers
  elephants-killed-by-climate-change ; counter to keep track of the number of elephants killed by climate change
  max-poacher   ; don't let the poachers population grow out of control
]

breed [ elephants elephant ]
breed [ poachers poacher ]

poachers-own [ settled? ]
turtles-own [ age ]

to setup

  clear-all
  ask patches [ set pcolor blue - 0.25 - random-float 0.25 ]
  import-pcolors "KrugerPark-V4 ica.png"
  ask patches with [ not shade-of? blue pcolor ] [
    ; seperating land from water body
    set pcolor green
  ]

  set-default-shape elephants "elephant"
  create-elephants number-of-elephants [
    set size 2
    set color black
    set age random (30 * 12)  ; average elephant age is 15
    move-to one-of patches with [ pcolor = green ]
  ]

  set-default-shape poachers "person"
  create-poachers number-of-poachers [
    set size 2
    set color red
    move-to one-of patches with [ pcolor = green and pxcor <= 10 ]
    set heading -5 + random 10 ; generally head east
    set settled? false
    set age random (50 * 12) ; average poacher age is 25
  ]

  set elephants-killed-by-climate-change 0
  set elephants-killed-by-poachers 0

  reset-ticks
end

to go
  ; stop the model if there are no elephants and the number of poachers gets very large
  if not any? elephants and count poachers > max-poacher [ user-message "The elephants are exctint from this Conservation area" stop ]

  ; stop the model if there are no poachers and the number of elephants get very large
  if not any? poachers and count poachers = max-poacher [ user-message "NO MORE THREAT, The elephants are replenished in this conservation area" stop ]


  ask patches with [ pcolor = green ] [
    ; at each step, patches have a small chance
    ; to become inhospitable for elephants
    if random-float 100 < Natural-death/climate-change [
      set pcolor green + 1
    ]
  ]

  ; elephants move and reproduce
  ask elephants [
    move elephant-speed
    ; elephants reproduce after age 3
    reproduce (3 * 12) elephant-birth-rate
  ]
  ask poachers [
    let elephants-nearby elephants in-radius 5
    ; poachers have a chance of settling proportional to the
    ; number of elephants in their immediate vicinity
    if not settled? and random 100 < count elephants-nearby [
      set settled? true
    ]
    if not settled? [
      if any? elephants-nearby [
        face min-one-of elephants-nearby [ distance myself ]
      ]
      move poacher-speed
    ]
    if any? elephants-here [
      let r random 100
      if r < 2.5 [ die ] ; elephants have a 2.5% chance of killing the poacher
      if r < 2.5 + demand-killing_rate [
        ask one-of elephants-here [ die ] ; successfully hunt a elephant!
        set elephants-killed-by-poachers elephants-killed-by-poachers + 1
      ]
    ]
    reproduce (12 * 12) poacher-spread-rate ; poachers reproduce after age 12
  ]
  die-naturally ; elephants die if they're old
  ask turtles [ set age age + 1 ]
  tick
end

to move [ dist ] ; poacher or elephant procedure
  right random 30
  left random 30
  ; avoid moving into the ocean or outside the world by turning
  ; left (-10) or right (10) until the patch ahead is not an ocean patch
  let turn one-of [ -10 10 ]
  while [ not land-ahead dist ] [
    set heading heading + turn
  ]
  forward dist
end

to-report land-ahead [ dist ]
  let target patch-ahead dist
  report target != nobody and shade-of? green [ pcolor ] of target
end

to reproduce [ min-age birth-rate ]
  if age >= min-age and random 100 < birth-rate [
    hatch 1 [
      set age 0
      if breed = poachers [ set settled? false ]
    ]
  ]
end

to die-naturally

  ask poachers [
    ; poachers have a 5% chance of dying if they're over 50
    if age > 50 * 12 and random-float 100 < 5 [ die ]
    ; they also get another 5% chance of dying if their density is too high
    if density > 0.75 and random-float 100 < 5 [ die ]
    ; in addition, all poachers have a 0.33% chance of dying.
    if random-float 100 < 0.33 [ die ]
  ]

  ask elephants [
    ; elephants have a 5% chance of dying if they're over 30
    if age > 30 * 12 and random-float 100 < 5 [ die ]
    ; they also get another 5% chance of dying if their density is too high
    if density > 0.50 and random-float 100 < 5 [ die ]
    ; if they are on a patch affected by climate change, they get a 5% chance of dying
    if [ pcolor ] of patch-here = green + 1 and random-float 100 < 5 [
      set elephants-killed-by-climate-change elephants-killed-by-climate-change + 1
      die
    ]
    ; finally, all elephants have a 0.33% chance of dying.
    if random-float 100 < 0.33 [ die ]
  ]

end

to-report density ; turtle reporter
  let nearby-turtles (turtle-set turtles-on neighbors turtles-here)
  report (count nearby-turtles with [ breed = [ breed ] of myself ]) / 9
end

; End of code
@#$#@#$#@
GRAPHICS-WINDOW
460
20
1048
609
-1
-1
5.98
1
10
1
1
1
0
0
0
1
0
96
0
96
1
1
1
months
30.0

MONITOR
1095
15
1175
60
Months
ticks / 12
0
1
11

SLIDER
60
450
415
483
poacher-spread-rate
poacher-spread-rate
0
20
4.0
1
1
%
HORIZONTAL

SLIDER
60
390
415
423
elephant-birth-rate
elephant-birth-rate
0
10
7.0
1
1
%
HORIZONTAL

SLIDER
60
510
415
543
demand-killing_rate
demand-killing_rate
1
97
5.0
1
1
%
HORIZONTAL

SLIDER
60
210
415
243
number-of-poachers
number-of-poachers
0
100
17.0
1
1
NIL
HORIZONTAL

SLIDER
60
150
415
183
number-of-elephants
number-of-elephants
100
2000
1352.0
1
1
NIL
HORIZONTAL

BUTTON
90
90
150
123
setup
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
310
90
370
123
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

PLOT
1095
90
1455
255
Impact on Population 
Months
Frequency/Num
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"elepants population" 1.0 1 -16777216 true "" "plot count elephants"
"Poaching rate" 1.0 0 -2674135 true "" "plot count poachers"

SLIDER
60
270
415
303
poacher-speed
poacher-speed
0
1
0.6
0.05
1
patches
HORIZONTAL

SLIDER
60
330
415
363
elephant-speed
elephant-speed
0
1
0.2
0.05
1
patches
HORIZONTAL

MONITOR
1300
15
1407
60
Poach counts
count poachers
17
1
11

MONITOR
1180
15
1295
60
elephants
count elephants
17
1
11

SLIDER
60
570
415
603
Natural-death/climate-change
Natural-death/climate-change
0.001
0.1
0.007
0.001
1
%
HORIZONTAL

PLOT
1095
265
1455
425
Cause of elephant Deaths
Months
Frequency
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"poachers" 1.0 0 -5207188 true "" "plot elephants-killed-by-poachers"
"natural deaths" 1.0 0 -8732573 true "" "plot elephants-killed-by-climate-change"

TEXTBOX
15
25
450
96
POACHING EFFECT ON ELEPHANT POPULATION IN EAST AFRICA CONSERVATION AREAS
20
104.0
1

BUTTON
195
90
267
123
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

PLOT
1095
435
1255
605
Safety bar
NIL
Demand vs Supply
1.0
1.0
1.0
1.0
true
true
"" ""
PENS
"Elephant SAFE" 0.0 2 -13840069 true "" "plot count elephants"
"Threat/ Supply" 0.0 2 -2674135 true "" "plot count poachers"

PLOT
1265
435
1455
605
Ivory chain
NIL
NIL
0.0
3.0
0.0
10.0
true
true
"" ""
PENS
"Ivory prive" 100.0 2 -2674135 true "" "plot count poachers + 100"
"Ivory available" 100.0 2 -13840069 true "" "plot count elephants + 100"

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7566196 true true 150 5 40 250 150 205 260 250

elephant
false
0
Polygon -7500403 true true 195 181 180 196 165 196 166 178 151 148 150 165 150 165 61 178 45 196 30 196 16 178 16 163 1 133 16 103 46 88 106 73 166 58 196 28 226 28 255 78 270 165 255 165 241 118 226 118 211 133
Rectangle -7500403 true true 165 195 180 225
Rectangle -7500403 true true 30 195 45 225
Rectangle -16777216 true false 165 225 180 240
Rectangle -16777216 true false 30 225 45 240
Line -16777216 false 255 90 240 90
Polygon -7500403 true true 0 165 0 135 15 135 0 165

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105
@#$#@#$#@
NetLogo 6.3.0
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
1
@#$#@#$#@
