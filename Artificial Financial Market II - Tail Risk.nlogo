__extensions ["sound.jar"]

patches-own [
             ;;;;;;;; Value Investor Variables ;;;;;;
             value_my_memory ;; Each value investor has a finite memory
             past_meaning ;; Past information meaning remembered by the agent, up to a finite horizon defined by the agent's memory
             average-meaning ;; The average information meaning regarding value that is reflected in the sentiment formation rule
             my-sentiment ;; The value investor sentiment (-1 (pessimistic), +1 (optimistic))
             value-order  ;; The value investor's market order (-1 (sell if pessimistic), +1 (buy if optimistic))
             opinion-vol  ;; Volatility in a trader's own interpretation of the information and of the neighbours sentiment.
             propensity-to-sentiment-contagion ;; Propensity to be influenced by others' sentiments regarding the news qualitative nature.
             base-propensity-to-sentiment-contagion ;; Inherent openess to others
             news-sensitivity ;; Sensitivity that the traders have to the news qualitative meaning.
             ;;;;;; Speculator Variables ;;;;;;
             up   ;; The speculator determines if the market was bullish or bearish
             strategy ;; The speculator chooses a strategy from the set of four strategies available
             speculator-action ;; The speculator chooses an action according to the market sentiment and to the strategy followed
             speculator-score  ;; The speculator score is a list (each speculator has a memory of past scores, controlled by the user)
             average-speculator-score ;; The average score
             innovation-point ;; Determines the point in the binary string of the strategy in which innovation takes place (this is similar to mutation in GAs)
             speculator-market-order ;; The speculator's market order
             
             ;;;;; Trend Follower Variables ;;;;
                                       
             time-delay ;; Defines the time-scale for the trend follower
             who_am_I ;; Each trend-follower defines his/her identity as a speculator as either a simple trend follower or a contrarian investor
                      ;; (the identity of each trend follower is socially learned and there is a social evolution of trend follower identity similar to the one
                      ;; that occurs in speculator strategies
             trend-follower-action ;; The action taken depends on the identity (contrarian, not contrarian, of the trend follower)
             trend-follower-score  ;; The trend follower score
             average-trend-follower-score ;; The average trend follower score
             trend-market-order ;; The trend follower's market order
             
             ]
             
turtles-own [interval frequency relative-frequency] ;; The turtle's variables are used to produce the histogram

globals [time
         clock ; Used to define the initial news qualitative meaning history
         log-price
         returns
         past-returns ;; A record of past returns
         initial_history ;; A record of an initial history regarding the news
         returns-variance
         volatility
         news-qualitative-meaning  ;; There is a set of news concerning the market that reaches all traders
                                   ;; these news are attributed a qualitative meaning
                                   
         ;;; Elements for the determination of the Tail Exponential Risk Measure ;;
         tail_risk_aversion
         tail_exponential
         pain_history
         current_pain
         ] 

to setup
ca
crt 21 ;; The 21 turtles are used to produce the histogram
set log-price 0
set returns 0
set time 0
set clock 0
set past-returns n-values returns-history [0] ; The market did not exist before the initial time so the initial returns are zero
set pain_history n-values time_window [0]
;;;;;;;;;;;;;;; Value Investors ;;;;;;;;;;;;;;;;;;;
ask patches [
             set opinion-vol sigma + random-int-or-float 0.1 ;; The value investor's opinion volatility is kept small, according to the assumption that the news contain 
             ;; the relevant information for the assessment of the fundamental value
             set news-sensitivity (random-int-or-float max-news-sensitivity)
             set base-propensity-to-sentiment-contagion (random-int-or-float max-base-propensity-to-sentiment-contagion)
             set propensity-to-sentiment-contagion base-propensity-to-sentiment-contagion
             set value_my_memory random value_memory + 1
             set past_meaning n-values value_memory [0]
             ]
;;;;;;;;;;;;;;;;; Speculators ;;;;;;;;;;;;;;;;;;;;;

ask patches [setup-strategy
             setup-gains]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;; Trend-Followers ;;;;;;;;;;;;;;;;

ask patches [setup-identities
             setup-time-delays]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; The turtle procedures are used solely for the porpuses of building the Histogram
ask turtle 0 [set interval 1]
ask turtle 1 [set interval 2]
ask turtle 2 [set interval 3]
ask turtle 3 [set interval 4]
ask turtle 4 [set interval 5]
ask turtle 5 [set interval 6]
ask turtle 6 [set interval 7]
ask turtle 7 [set interval 8]
ask turtle 8 [set interval 9]
ask turtle 9 [set interval 10]
ask turtle 10 [set interval 11]
ask turtle 11 [set interval 12]
ask turtle 12 [set interval 13]
ask turtle 13 [set interval 14]
ask turtle 14 [set interval 15]
ask turtle 15 [set interval 16]
ask turtle 16 [set interval 17]
ask turtle 17 [set interval 18]
ask turtle 18 [set interval 19]
ask turtle 19 [set interval 20]
ask turtle 20 [set interval 21]
ask turtles [set frequency 0
             set relative-frequency 0
             ht
             ]
end

 ;;;;;;;;;;;;;
 ;Speculators;
 ;;;;;;;;;;;;;

to setup-strategy
set strategy n-values 2 [random 2]
end

to  setup-gains
set speculator-score n-values speculator-memory [0]
set trend-follower-score n-values trend-follower-memory [0]
end

  ;;;;;;;;;;;;;;;;;
  ;Trend-Followers;
  ;;;;;;;;;;;;;;;;;

to setup-identities
set who_am_I random 2 ;; If who-am-I = 0, then, the agent is not a contrarian, if who-am-I = 1, the agent is a contrarian
end

to setup-time-delays
set time-delay random returns-history ;; Each trend follower has a different time-delay, that is, they address different time-horizons of past returns information
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; Although the market did not exist before the initial time, there is economic information available before, so we provide for a initial history

to setup-past-history
set clock clock + 1
if clock > value_memory [stop]
ifelse (random-normal 0 1) > 0
         [set news-qualitative-meaning 1]
         [set news-qualitative-meaning -1] 
ask patches [set past_meaning lput news-qualitative-meaning but-first past_meaning]
end


to go
set time time + 1
news-arrival
agent-decision
market-clearing

;;;; Value investors ;;;;
update-market-sentiment
;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;; Speculators and Trend-followers ;;;;;
ask patches [collect-gains]
ask patches [learn]
if innovation? [ask patches [innovate]]
;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;; Tail Risk ;;;;;;;;;;
compute-volatility-indicator
ask turtles [count-returns]
compute-TE
if plot? [do-plot]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end


;;;;;;;;;;;;;;;;;;;;;;;;;;
; News Arrival mechanism ;
;;;;;;;;;;;;;;;;;;;;;;;;;;
to news-arrival
ifelse (random-normal 0 1) > 0
         [set news-qualitative-meaning 1]
         [set news-qualitative-meaning -1]
ask patches [set past_meaning lput news-qualitative-meaning but-first past_meaning
             set average-meaning reduce [?1 + ?2] past_meaning / value_my_memory
             ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;
; Agent's decision rule ;
;;;;;;;;;;;;;;;;;;;;;;;;;


to agent-decision
    ask patches [
                ifelse ((propensity-to-sentiment-contagion * nsum6 (my-sentiment) + news-sensitivity * average-meaning + random-normal miu opinion-vol) > 0)
                   [set my-sentiment 1
                   set value-order 1] ;; Buy
                   [set my-sentiment -1
                    set value-order -1] ;; Sell
                    ]


if board = 0 ; board = 0 is the value investors board
; If the agent's sentiment is positive the colour is set green, if he is negative it is set red.

 [ask patches [if my-sentiment = 1 [set pcolor green]
              if my-sentiment = -1 [set pcolor red]
                                        ]
                                          ]

if board = 1 [speculator-colorscheme] ; board = 1 is the speculator's board

if board = 2 [trend-follower-colorscheme] ; board = 2 is the trend follower's board
 

; Speculators determine if the last period returns were greater than zero or not and then they choose their actions according to the strategy.

ifelse returns >= 0 [ask patches [set up 1]] [ask patches [set up 0]]
ask patches [choose-action]

end



to choose-action

; Speculators

if up = 0 and item 0 strategy = 0 [set speculator-action 0] ; If the market was bearish in the last period, the speculator sells under the strategy [00] or [01]
if up = 0 and item 0 strategy = 1 [set speculator-action 1] ; If the market was bearish in the last period, the speculator buys, under the strategy [10] or [11]
if up = 1 and item 1 strategy = 0 [set speculator-action 0] ; If the market was bullish in the last period, the speculator sells, under the strategy [00] or [10]
if up = 1 and item 1 strategy = 1 [set speculator-action 1] ; If the market was bullish in the last period, the speculator buys, under the strategy [01] or [11]
ifelse (speculator-action = 1) [set speculator-market-order 1] [set speculator-market-order -1]

; Trend-followers
ifelse who_am_I = 0 [if item time-delay past-returns < 0 [set trend-follower-action -1]
                     if item time-delay past-returns = 0 [set trend-follower-action 0]
                     if item time-delay past-returns > 0 [set trend-follower-action 1]]
; A non-contrarian buys if the past returns were positive and sells if the past returns were negative

                    [if item time-delay past-returns < 0 [set trend-follower-action 1]
                     if item time-delay past-returns = 0 [set trend-follower-action 0]
                     if item time-delay past-returns > 0 [set trend-follower-action -1]]                     
; A contrarian sells if the past returns were positive and buys if the past returns were positive

set trend-market-order trend-follower-action
end



;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Market clearing mechanism ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to market-clearing
set returns ((value-investors-strength * sum values-from patches [value-order] + (1 - value-investors-strength) * (trend-followers-strength * sum values-from patches [trend-market-order] + (1 - trend-followers-strength) * sum values-from patches [speculator-market-order]))  / count patches) / theta
set log-price (log-price + returns)
set past-returns lput returns but-first past-returns
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;
; Update market sentiment;
;;;;;;;;;;;;;;;;;;;;;;;;;;

to update-market-sentiment
ask patches [; A good(bad) news confirmed by a market movement in the direction of that news
             ; leads to a greater propensity to sentiment contagion. If the good(bad) news is not
             ; confirmed by a market movement in the same direction the propensity to sentiment contagion
             ; decreases.
             if (returns > 0) and (news-qualitative-meaning > 0)
                [set propensity-to-sentiment-contagion base-propensity-to-sentiment-contagion + returns * theta]
             if (returns > 0) and (news-qualitative-meaning < 0)
                [set propensity-to-sentiment-contagion base-propensity-to-sentiment-contagion - returns * theta]
             if (returns < 0) and (news-qualitative-meaning < 0)
                [set propensity-to-sentiment-contagion base-propensity-to-sentiment-contagion - returns * theta]
             if (returns < 0) and (news-qualitative-meaning > 0)
                [set propensity-to-sentiment-contagion base-propensity-to-sentiment-contagion + returns * theta]

                ]       
end


to collect-gains
; Speculators and contrarians try to be on the minority side, this reflects the way they keep scores

;;;; Speculators ;;;;
if (returns > 0 and speculator-action = 0) [set speculator-score lput 1 but-first speculator-score]
if (returns > 0 and speculator-action = 1) [set speculator-score lput -1 but-first speculator-score]
if (returns <= 0 and speculator-action = 0) [set speculator-score lput -1 but-first speculator-score]
if (returns <= 0 and speculator-action = 1) [set speculator-score lput 1 but-first speculator-score]
set average-speculator-score (reduce [?1 + ?2] speculator-score) / speculator-memory

;;;;; Trend-Followers ;;;;
ifelse who_am_I = 0 [if (returns > 0 and trend-follower-action > 0) [set trend-follower-score lput 1 but-first trend-follower-score]
                     if (returns > 0 and trend-follower-action < 0)  [set trend-follower-score lput -1 but-first trend-follower-score]
                     if (returns < 0 and trend-follower-action < 0)  [set trend-follower-score lput 1 but-first trend-follower-score]
                     if (returns < 0 and trend-follower-action > 0)  [set trend-follower-score lput -1 but-first trend-follower-score]
                      ]
                    [if (returns > 0 and trend-follower-action > 0) [set trend-follower-score lput -1 but-first trend-follower-score]
                     if (returns > 0 and trend-follower-action < 0)  [set trend-follower-score lput 1 but-first trend-follower-score]
                     if (returns < 0 and trend-follower-action < 0)  [set trend-follower-score lput -1 but-first trend-follower-score]
                     if (returns < 0 and trend-follower-action > 0)  [set trend-follower-score lput 1 but-first trend-follower-score]
                      ]
if (returns = 0 and trend-follower-action = 0) [set trend-follower-score lput 1 but-first trend-follower-score]
set average-trend-follower-score (reduce [?1 + ?2] trend-follower-score) / trend-follower-memory
end

to learn
ifelse (average-speculator-score < average-speculator-score-of max-one-of neighbors6 [average-speculator-score]) [learn-from-neighbour-speculator] [reproduce-speculator]
ifelse (average-trend-follower-score < average-trend-follower-score-of max-one-of neighbors6 [average-trend-follower-score]) [learn-from-neighbour-trend-follower] [reproduce-trend-follower]
end

to learn-from-neighbour-speculator
set strategy strategy-of max-one-of neighbors6 [average-speculator-score]
end

to learn-from-neighbour-trend-follower
set who_am_I who_am_I-of max-one-of neighbors6 [average-trend-follower-score]
end

to reproduce-speculator
set strategy strategy
end

to reproduce-trend-follower
set who_am_I who_am_I
end

to innovate
ifelse random-float 1.000 < p-speculator 
     [set innovation-point random 2
      ifelse ((item innovation-point strategy) = 1) 
           [set strategy replace-item innovation-point strategy 0]
           [set strategy replace-item innovation-point strategy 1]
           ]           
     [set strategy strategy]
ifelse random-float 1.000 < p-trend-follower
      [ifelse who_am_I = 0 [set who_am_I 1] [set who_am_I 0]]
      [set who_am_I who_am_I]
end


to speculator-colorscheme

ifelse strategy-color? [ask patches [if (item 0 strategy = 0) and (item 1 strategy = 0) [set pcolor blue] ; Sell no matter what
                                     if (item 0 strategy = 0) and (item 1 strategy = 1) [set pcolor yellow] ; Sell, if bearish, buy if bullish
                                     if (item 0 strategy = 1) and (item 1 strategy = 0) [set pcolor cyan] ; Buy, if bearish, sell if bullish
                                     if (item 0 strategy = 1) and (item 1 strategy = 1) [set pcolor magenta] ; Buy no matter what
                                     ]]
                       [ask patches [ifelse speculator-action = 1 [set pcolor green] [set pcolor red]]
                        ]              
end

to trend-follower-colorscheme
ifelse strategy-color? [ask patches [if (who_am_I = 0) [set pcolor blue]
                                    if (who_am_I = 1) [set pcolor white]]
                                    ]
                       [ask patches [if trend-follower-action = 1 [set pcolor green] 
                                     if trend-follower-action = 0 [set pcolor black]
                                     if trend-follower-action = -1 [set pcolor red]]
                       ]
                                    

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;
; RISK INDICATORS ;
;;;;;;;;;;;;;;;;;;;;;;;;


to compute-volatility-indicator
set returns-variance decay-factor * returns-variance + (1 - decay-factor) * (returns ^ 2)
set volatility returns-variance ^ 0.5
end


to count-returns
if (returns >= -0.1 and returns < -0.09) and interval = 0 [set frequency frequency + 1]
if (returns >= -0.09 and returns < -0.08) and interval = 1 [set frequency frequency + 1]
if (returns >= -0.08 and returns < -0.07) and interval = 3 [set frequency frequency + 1]
if (returns >= -0.07 and returns < -0.06) and interval = 4 [set frequency frequency + 1]
if (returns >= -0.06 and returns < -0.05) and interval = 5 [set frequency frequency + 1]
if (returns >= -0.05 and returns < -0.04) and interval = 6 [set frequency frequency + 1]
if (returns >= -0.04 and returns < -0.03) and interval = 7 [set frequency frequency + 1]
if (returns >= -0.03 and returns < -0.02) and interval = 8 [set frequency frequency + 1]
if (returns >= -0.02 and returns < -0.01) and interval = 9 [set frequency frequency + 1]
if (returns >= -0.01 and returns < 0.0) and interval = 10 [set frequency frequency + 1]
if (returns >= 0.0 and returns < 0.01) and interval = 11 [set frequency frequency + 1]
if (returns >= 0.01 and returns < 0.02) and interval = 12 [set frequency frequency + 1]
if (returns >= 0.02 and returns < 0.03) and interval = 13 [set frequency frequency + 1]
if (returns >= 0.03 and returns < 0.04) and interval = 14 [set frequency frequency + 1]
if (returns >= 0.04 and returns < 0.05) and interval = 15 [set frequency frequency + 1]
if (returns >= 0.05 and returns < 0.06) and interval = 16 [set frequency frequency + 1]
if (returns >= 0.06 and returns < 0.07) and interval = 17 [set frequency frequency + 1]
if (returns >= 0.07 and returns < 0.08) and interval = 18 [set frequency frequency + 1]
if (returns >= 0.08 and returns < 0.09) and interval = 19 [set frequency frequency + 1]
if (returns >= 0.09 and returns < 0.1) and interval = 20 [set frequency frequency + 1]
set relative-frequency frequency / time
end

to compute-TE
set tail_risk_aversion base_tail_risk_aversion * volatility
if (returns < (0 - Threshold)) 
       [set current_pain exp(0 - (tail_risk_aversion * returns))
        set pain_history lput current_pain but-first pain_history]
set tail_exponential ((reduce [?1 + ?2] pain_history) / time_window)
end



;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

to do-plot
if time >= 100 [plot-histogram]
set-current-plot "Log-price"
set-current-plot-pen "log-price"
plot log-price
set-current-plot "Returns"
set-current-plot-pen "returns"
plot returns
set-current-plot "Volatility"
set-current-plot-pen "volatility"
plot volatility
set-current-plot "Tail Exponential"
set-current-plot-pen "TE"
if time >= 100 [plot ln(tail_exponential) / tail_risk_aversion
                if music_tail_risk? [start-note "Jazz Electric Guitar" 50 + ln(tail_exponential) / tail_risk_aversion * 100  90 + returns * 100]
                if music_tail_risk_aversion? [start-note "Steel Acoustic Guitar" 50 + tail_risk_aversion 90 + returns * 100]
                ]
set-current-plot "Tail Risk - Returns Space"
set-current-plot-pen "trajectory"
if time > 1000 [if returns < 0 - Threshold [plotxy (ln(tail_exponential) / tail_risk_aversion) returns]]
end

to plot-histogram
set-current-plot "Histogram"
plot-pen-reset
set-plot-pen-color red
plot value-from turtle 0 [relative-frequency]
set-plot-pen-color yellow
plot value-from turtle 1 [relative-frequency]
set-plot-pen-color green
plot value-from turtle 2 [relative-frequency]
set-plot-pen-color blue
plot value-from turtle 3 [relative-frequency]
set-plot-pen-color magenta
plot value-from turtle 4 [relative-frequency]
set-plot-pen-color violet
plot value-from turtle 5 [relative-frequency]
set-plot-pen-color cyan
plot value-from turtle 6 [relative-frequency]
set-plot-pen-color pink
plot value-from turtle 7 [relative-frequency]
set-plot-pen-color brown
plot value-from turtle 8 [relative-frequency]
set-plot-pen-color black
plot value-from turtle 9 [relative-frequency]
set-plot-pen-color grey
plot value-from turtle 10 [relative-frequency]
set-plot-pen-color lime
plot value-from turtle 11 [relative-frequency]
set-plot-pen-color sky
plot value-from turtle 12 [relative-frequency]
set-plot-pen-color turquoise
plot value-from turtle 13 [relative-frequency]
set-plot-pen-color orange
plot value-from turtle 14 [relative-frequency]
set-plot-pen-color 82
plot value-from turtle 15 [relative-frequency]
set-plot-pen-color 92
plot value-from turtle 16 [relative-frequency]
set-plot-pen-color 102
plot value-from turtle 17 [relative-frequency]
set-plot-pen-color 122
plot value-from turtle 18 [relative-frequency]
set-plot-pen-color 132
plot value-from turtle 19 [relative-frequency]
end




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@#$#@#$#@
GRAPHICS-WINDOW
132
719
308
916
4
4
18.444444444444443
1
10
1
1
1
0
4

CC-WINDOW
5
930
2041
1025
Command Center

BUTTON
162
61
234
94
setup
setup
NIL
1
T
OBSERVER
T
NIL

BUTTON
430
64
485
97
go
go
T
1
T
OBSERVER
T
NIL

SLIDER
25
357
117
390
miu
miu
-1
1
0.0
0.01
1
NIL

SLIDER
132
356
224
389
sigma
sigma
0
1
0.9
0.0010
1
NIL

PLOT
1529
10
2032
157
Returns
time
returns
0.0
1000.0
-0.05
0.05
true
true
PENS
"Returns" 1.0 0 -44544 true

SLIDER
26
417
184
450
max-news-sensitivity
max-news-sensitivity
0
1
0.2
0.01
1
NIL

PLOT
937
16
1487
166
Log-price
time
log-price
0.0
1000.0
0.0
0.1
true
true
PENS
"log-price" 1.0 0 -16776961 true

PLOT
1502
185
2017
357
Volatility
time
volatility
0.0
1000.0
0.0
0.05
true
true
PENS
"volatility" 1.0 0 -8716033 true

TEXTBOX
416
280
632
298
SPECULATOR PARAMETERS

SLIDER
26
476
302
509
max-base-propensity-to-sentiment-contagion
max-base-propensity-to-sentiment-contagion
0
1
0.25
0.01
1
NIL

SLIDER
403
321
560
354
speculator-memory
speculator-memory
0
2000
10
1
1
NIL

SWITCH
771
318
890
351
innovation?
innovation?
0
1
-1000

SLIDER
601
319
715
352
p-speculator
p-speculator
0
1
0.01
0.0010
1
NIL

SLIDER
25
175
145
208
decay-factor
decay-factor
0
1
0.94
0.01
1
NIL

SWITCH
28
10
131
43
plot?
plot?
0
1
-1000

SLIDER
30
591
220
624
value-investors-strength
value-investors-strength
0
1
0.7
0.01
1
NIL

TEXTBOX
26
290
176
320
VALUE INVESTOR PARAMETERS

TEXTBOX
412
374
562
404
TREND FOLLOWER PARAMETERS

SLIDER
620
483
805
516
trend-follower-memory
trend-follower-memory
0
2000
20
1
1
NIL

SLIDER
158
10
330
43
board
board
0
2
0
1
1
NIL

SWITCH
359
10
500
43
strategy-color?
strategy-color?
1
1
-1000

SLIDER
626
423
798
456
p-trend-follower
p-trend-follower
0
1
0.01
0.0010
1
NIL

SLIDER
393
425
565
458
maximum-delay
maximum-delay
0
100
50
1
1
NIL

SLIDER
396
483
586
516
trend-followers-strength
trend-followers-strength
0
1
0.5
0.01
1
NIL

PLOT
575
10
882
271
Histogram
Intervals
Frequency
0.0
20.0
0.0
0.5
true
false
PENS
"default" 1.0 1 -65536 true

TEXTBOX
23
133
173
151
TAIL RISK CALCULATIONS

SLIDER
30
227
132
260
Threshold
Threshold
0
1
0.0
0.01
1
NIL

SLIDER
169
174
277
207
time_window
time_window
0
100
20
1
1
NIL

SLIDER
166
225
358
258
base_tail_risk_aversion
base_tail_risk_aversion
0
100
100.0
0.01
1
NIL

PLOT
934
192
1457
432
Tail Exponential
time
Certain Loss Equivalent
0.0
1000.0
0.01
0.02
true
true
PENS
"TE" 1.0 0 -16777216 true

SLIDER
395
544
567
577
returns-history
returns-history
0
100
4
1
1
NIL

TEXTBOX
907
467
1119
662
SPECULATOR STRATEGY COLOUR CODE\n\nBLUE - Sell no matter what\n\nYELLOW - Sell if market fell, buy if market rose\n\nCYAN - Buy if market fell, sell if market market rose\n\nMAGENTA - Buy no matter what

TEXTBOX
1152
475
1393
565
TREND FOLLOWER COLOUR CODE\n\nBLUE if simple trend-follower\n\nWHITE if contrarion

SLIDER
29
536
201
569
value_memory
value_memory
0
100
20
1
1
NIL

SLIDER
31
60
123
93
theta
theta
0
100
10
1
1
NIL

BUTTON
249
61
408
94
NIL
setup-past-history
T
1
T
OBSERVER
T
NIL

SWITCH
392
120
535
153
music_tail_risk?
music_tail_risk?
0
1
-1000

PLOT
1500
398
1956
740
Tail Risk - Returns Space
Returns
Certain Loss Equivaleny
-0.06
0.1
-0.01
0.01
true
false
PENS
"trajectory" 1.0 2 -16777216 true

SWITCH
358
170
556
203
music_tail_risk_aversion?
music_tail_risk_aversion?
1
1
-1000

@#$#@#$#@
WHAT IS IT?
-----------

This model features an artificial financial market with speculators, trend followers and value investors. Its main new features are the following:

1) It includes new agent types (that were not present in the previous artificial financial market), namely: speculators and trend followers;

2) It endows speculators and trend followers of a learning scheme based on social learning;

3) It determines a new risk measure introduced recently in the financial literature (Gonçalves, 2004, Gonçalves and Ferreira, 2004) that possesses important features like tail risk freeness (that is, it reflects the whole of the information regarding the probabilities associated with extreme events).

4) The emerging patterns regarding tail risk and the price logarithm produce music.

5) The agent grid is three-dimensional.

This presentation is divided as follows:

PART 1: Part 1 reviews the problem of tail risk and the main issues regarding the problem of undetected tail risk. It also introduces the tail exponential risk measure.

PART 2: Part 2 presents each agent type and behaviour;

PART 3: Part 3 introduces the musical analysis of tail risk;

PART 4: Part 4 describes the basic interface with the user;

PART 5: Part 5 addresses things to notice and things to try.


------------------
PART 1: TAIL RISK
------------------

The problem of tail risk is a central problem to the globalized financial markets. This problem can, roughly, be summed up in the following idea - the change, with time, in the probabilities of extreme losses makes these losses more probable at some times, and less probable at others. Large investments may incur in large losses, if the agent holds these investments at times when the probability of extreme losses is high, then the agent is at risk of losing large amounts.

Extreme losses are usually located at the tails of the probability distributions, this, along with the fact that the risk associated with extreme losses comes from changes in these tails probabilities, leads to the concept of tail risk.

It is essential that a risk measure be able to dynamically reflect the risk of these extreme losses in the financial markets, in order to control for this kind of risk.

As Yasuhiro Yamai and Toshinao Yoshiba (2001, 2002a) showed, most tail risk measures (including the widely used VaR and CVaR) are unable to reflect this extreme loss risk in their risk measurement, thus, undetected unaccounted for tail risk may be present. This is what the authors called non tail risk freeness.

A risk measure is said to be free of tail risk if it is able to reflect in its measurement, the risk contained in the tails of the underlying distributions. If a risk measure is unable to reflect the risk contained in the tails, then, it is not to free of tail risk.

Recently, Gonçalves (2004) proposed a tail risk measure that is free of tail risk. This risk measure was called Tail Exponential Risk Measure, or TE, for short.

The TE is determined as follows:

TE = E[exp(L.X)|X > K)

L - tail risk aversion coefficient
X - Losses (losses are defined as the symmetric of the logarithmic returns in this case)
K - Loss threshold

The exponential may be seen as playing the role of a pain function (the symmetric of a utility function), thus expressing displeasure (Gonçalves and Ferreira, 2004). The tail exponential is, thus, the "expected pain", associated with the tail that is defined by the event X > K.

Mathematically, the Tail Exponential measures a new notion of tail risk introduced by Gonçalves (2004), the notion of pK-tail risk. The pK-tail risk is the risk contained in the conditional loss probability measure, conditional on the event that the losses are greater than the threshold K.

The tail exponential measures the risk contained in this conditional probability measure (Gonçalves (2004), Gonçalves and Ferreira (2004)).

In this model, we let the tail risk aversion coefficient change, with time, by setting it equal to a base tail risk aversion coefficient, times the estimate of the volatility parameter (the volatility parameter is determined by using RiskMetrics (TM) Exponentially Weighted Moving Average volatility estimate).

Although the phenomenon of tail risk was largely researched upon at a theoretical level, specifically, at the level of the properties that a risk measure should satisfy. Once we have a risk measure that is capable of reflecting the whole of the information regarding the tails beyond a threshold K, it is important to consider other aspects of the phenomenon of tail risk, namely, its dynamical nature.

The present model has, as one of its main goals, to allow the financial researcher and the economist or any other researcher interested in financial markets phenomena and group behaviour, to explore the dynamical features of tail risk. Specifically:

a) The changes that occur, through time, in tail risk (especially the presence of trends in tail risk, and the changes that can be seen in real time in the histogram);

b) The relation between tail risk and synchronization in asset trading;

c) The relation between tail risk and financial crashes.


The model also introduces new kinds of agents with learning rules that evolve with time, so that the model is also intended to make some contributions to complex systems theory and the view of a financial market as a complex adaptive system.

------------------------------------------
PART 2: AGENT TYPES AND BEHAVIOURAL RULES
-------------------------------------------


MARKET MAKER
------------


The market maker appears in the artificial financial market only in terms of the price formation rule, that is, the market maker is treated solely in terms of the market clearing mechanism.

The agents can, then, be divided in two large typologies. Specifically, a first type of agents, that includes value investors, speculators and trend followers, that place their orders to buy or sell stock, a second type of agents, or, in this case, a unique agent that is the market maker.

The market maker guarantees that the market clears by taking up the excess demand or supply. Therefore, the orders are filled by the market maker at a price that depends on the net order of the first type of traders. The market impact function f is the mechanism that the market maker uses to set the prices, which leads to a market clearing mechanism that can be expressed in terms of a price formation rule relating the net order to the new price.

At each time step we take the price to be a function of the net order W{t} which is a difference between the demand and the supply, therefore, the market maker uses the following algorithm to compute the price:

	P{t+1}=f(P{t},W{t})

Following Farmer (2000), assuming that f is of the form

	f(P{t},W{t})=P{t}F(W{t})

where the market impact function F(W(t)) is taken to be an increasing function with F(0)=1, leads to the log-linear market impact function (Farmer, 2000). In this case the logarithmic returns y{t} are given by:

	y{t}=lnP{t}-lnP{t-1} = W{t})/ L

where L is a normalizing liquidity parameter.

The net order is taken to be equal to the weighted sum of the net orders of the three agent types, the weights convert orders from quantity (number of shares) to money, amount being bought, or sold.

We take the parameter L to be equal to theta times G, and let, G be such that the sum of the weights divided by G is equal to 1. The quotient between each weight and the parameter G represents the impact, to the market, of each agent type.

Thus, the price formation rule is similar to the one proposed by Farmer (2000), with the difference that instead of the net order we have an average net order, E[W{t}] averaged over the agent types. The logarithmic returns are, then, given by:

	y{t}=((E[W{t})]/theta)

As we saw in the previous artificial financial market, the expected value E[W(t)] can be thought of as a measure of the average market sentiment, or of sentiment polarization. This variable has also been previously called 'groupthink' (Ponzi, Aizawa, 1999).


The logarithm of price p{t}=ln(P{t}) is given by:

	p{t}=p{t-1}+y(t) = p{t-1}+((E[W{t})] / theta)

Having discussed the market maker, and the price formation rule, we now address each agent type.
    

VALUE INVESTORS (BOUNDED RATIONALITY AND SOCIAL INFLUENCE IN GROUP DYNAMICS)
----------------------------------------------------------------------------

Value investors follow the previous artificial financial market's rules. They are agents that trade, based on the social learning of information that arrives to the market.

At each time step new information arrives to the market as a signal I(t).

A qualitative meaning is given to the information, this meaning is taken in binary terms as either being good (+1) or bad (-1), in this sense we have, at time t:

(1): I(t)~N(0,1)
(2): Q(t)=1 if I(t)>0, Q(t)=-1 otherwise

I(t) - New Information (news for short)
Q(t) - Qualitative meaning						

There are three behavioural assumptions underlying these agents:

Assumption 1) Individuals are boundedly rational.
Assumption 2) Individuals are heterogeneous.
Assumption 3) Individuals are open to the sentiments of their closest colleagues regarding the qualitative meaning of the information.

The fact that individuals are boundedly rational leads to limits in the interpretation of the information. These limits, in our case, need not come necessarily from different accesses to information, indeed all traders are informed traders and these limits are considered to be intrinsic to the individual.

The reason for this, is that, unlike the neoclassical agent that knew all in all of its dimensions, we assume that agents need to cognitively interpret their experiences, they form models of the world and of their position in the world, and these models differ from individual to individual (assumption 3). Indeed, the knowledge and experience, the background of each trader is different, so that they interpret the information differently, and they have to learn about the world, to make sense of it, and of their position in it.

In this sense, the sentiment regarding the market is formed differently for each trader, and each reacts differently to the information. The new information, however, is not the only external force acting at the agent level, we also have to take into account the possibility of social communication and of social transmission of sentiments regarding the qualitative meaning of the information. In this sense, we assume that there is some sensitivity of the individual to the sentiments of his/hers closest colleagues in the trader's network of relations.

This openness of the individual to others is a strategy of rationality expansion, given the limits of the individual's rationality.


The following rule (the sign function takes the value +1 when the argument is positive and -1 when the argument is negative) defines the agent's sentiment update rule:

(3): Si(t)=sign(Ki*NSi(t)+nsi*E[Q(t),h]+ei(t))

Ki - Propensity of the trader i to be contagiated with the friends sentiment.

NSi(t) - The sum of the trader i's friends sentiments.

nsi - the sensitivity of the trader i to the news qualitative meaning.

ei(t) - a random term that accounts for each individual's own interpretation of the news (called the idiosyncratic term (Sornette, 2003)), we take it to be normally distributed around zero and with standard-deviation to be controlled by the user.

Si(t) - trader i's sentiment regarding the information, if it is good (bullish) the trader buys if it is bad (bearish) the trader sells.

Q(t) - News qualitative meaning

E[Q(t),h] - The expected value of the news qualitative meaning, taken as an average over a time-period h (which varies from agent to agent).

Note that each of the elements that form the argument of the sign function differ from trader to trader, except the news qualitative meaning which is a common component.

There is a cognitive rule for the dynamics of the propensity to be contagiated by the sentiments of others.

We assume that individuals have a base propensity to be contagiated by the sentiments of others, and that, if a good(bad) news is confirmed by a market movement in the same direction, then the individual's propensity to contagion is set equal to his/hers base propensity plus(less) an amount equal value of to the average market polarization (measured by the 'groupthink', E(W(t))), otherwise the propensity to contagion is set equal to the base propensity less(plus) an amount equal to the average market polarization (E(W(t)).

The choice of E(W(t)) for the amount to be added or subtracted has to do with the fact that this is an indicator of the average aggregate state of the market, and it is related to the degree of herding, as we shall see later on in this presentation.

Let us give a basic intuition for this rule. Assume a pessimistic scenario (an optimistic would also serve as an example), more specifically, assume that a bad news arrives and that this bad news is confirmed by a market movement in the same direction. The market only confirms the bad news if there is a larger number of agents with a negative sentiment (bearish) relative to those with a positive sentiment (bullish), so that the aggregate sentiment is bearish, then, the traders become more sensitive to the others sentiments, and the bad sentiment catches on to the next period.


SPECULATORS (SOCIAL LEARNING PROCESS IN A MINORITY GAME)
--------------------------------------------------------

The speculators play a minority game with the market. Their strategies are taken to be one of the following four:

S1: Sell no matter what (strategy code: [00])
S2: Sell if the market was bearish in the last period, buy if it was bullish (strategy code: [01])
S3: Buy if the market was bearish in the last period, sell if it was bullish (strategy code: [10])
S4: Buy no matter what (strategy code: [11])

The speculators keep scores as follows: if the market went up and they bought, their score is set equal to -1 (they were not on the minority side), likewise, if the market went down and they sold, then, they were not on the minority side and their score is also set equal to -1. Their score is only set equal to 1 if the market rose and they sold, or if the market fell and they bought.

Speculators possess a finite memory of the past scores, which allows them to form a historical record of past scores. Given that record, they determine the average score; and compare their average scores with those of their six nearest neighbours in a 3 dimensional grid that forms the network of traders. Afterwards, if their average score is greater than the best score of the six nearest neighbours, the speculators reproduce the strategy. If not, they imitate the strategy of the best performer of the six nearest neighbours. Notice that the best performers are agents that, on average, have been in the minority side more times than their neighbours.

This is a social learning process, in the sense that each agent learns from her neighbours what strategy to implement.

We allow for individual creativity in the strategy selection process, by giving individuals the freedom to choose a strategy different from the one that follows from the social learning process. This is done by introducing a probability of strategy innovation.

If, in the course of strategy innovation, the individual finds a strategy that works better, then, this strategy may be learned by the neighbours and reproduced. This is largely what happens if, in the course of an individual strategy change, the local new strategy spreads to a number of agents in the vicinities (more or less like an avalanche process).

TREND FOLLOWERS (SOCIAL LEARNING, SOCIAL IDENTITIES AND STRATEGIES)
-------------------------------------------------------------------

Trend followers are agents that are not necessarily trying to play a minority game and do not pay attention to fundamental information, instead, they try to find patterns in price history and then they develop trading strategies based upon these patterns. 

We develop here a very simple model of trend following. In this case, we assume that the information that the trend followers use to predict the trend is the past returns at different time horizons, so that, if the price went up, they predict that it will go up and if it went down, they predict that it will go down.

That is, if y(t-m) are the returns at time t-m, then, if y(t-m) < 0, they predict that y(t+1) will be positive and vice-versa. The lag m, is the trend-follower time scale. Each trend-follower has a different time scale.

We model here two basic kinds of trend following strategies: contrarian investing, and simple trend following.

Contrarian investors play a minority game with the market, in the same way as speculators did, however, while the speculators may have different strategies, that do not necessarily coincide with the ones of the contrarian investors, contrarian investors' trading is completely mechanical in nature, more specifically, they sell if the y(t-m) > 0 and buy if y(t-m) < 0.

Simple trend followers, on the other hand, buy if y(t-m) > 0 (because they predict that it will continue rising) and sell if y(t-m) < 0 (because they predict that it will continue falling). Thus functioning as trend enhancers.

If the returns are equal to zero, both of the trend follower strategies hold (they do not buy nor sell).

Trend followers also possess a memory, and keep records of scores.

If the trend follower is a simple trend follower, then, her goal is to place an order that coincides with a market movement in the same direction, thus, they win if their market order coincides with the majority (score 1) and lose (score -1) if their market order coincides with the minority.

If the trend follower is a contrarian, then her goal is to place an order that is opposite to the market movement (the exact opposite of a simple trend follower), they thus win (score 1) if their order coincides with the minority and lose (score -1) if their order coincides with the majority.

The social learning here is similar to the one of the speculators at the level of the learning algorithm. Namely, the agent's imitate the best local performer, and they also innovate in their investment strategies.

The difference here is that, instead of selecting a strategy, what we have is a social identity selection. That is, the agent either considers herself to be a simple trend follower or a contrarian, according to the success that the nearest trend followers and contrarian have.


---------------------------------------
PART 3: EMERGENCE, MUSIC AND TAIL RISK
---------------------------------------

One important finding of this artificial financial market is that despite the randomness there are emerging patterns in tail risk. The simulation transforms in a musical scale a comparison between the tail risk aversion parameter and the returns (switch music_tail_risk_aversion?) and between the tail exponential and the returns.

The comparison between the tail exponential and the returns, is done as follows:

A) If TE is the value of tail risk associated with the conditional probability measure, then,

B) ln(TE) / L is the certain loss equivalent, that is the amount of logarithmic losses that suffered with certainty would be considered to be equivalent to the random loss X, conditional on the event that it is greater than K.

It is the certain loss equivalent rather than the TE that is compared with the returns in the musical pattern (switch music_tail_risk?).

We can capture musical patterns and literally hear the tail risk increasing and decreasing.

The emerging musical patterns in tail risk betray the emergence of changing patterns in the fluctuations of the tails. It reflects the main feature of the model's dynamics the constant change of phase from disordered to ordered states.

These patterns change as the threshold is increased. For the threshold equal to zero, the tail exponential reflects the tail risk contained in the left tail of the returns probability distribution (that is, it reflects the tail risk contained in the loss probability distribution). This is the default configuration.

The user may increase slowly the parameter and hear the changes in the patterns.

The fact that the price and the tail risk contain musical patterns is an example of how structure and meaning emerges from the agent behaviour and interaction, even despite the underlying randomness of the news signal that arrives, the agent's behaviour produce emerging patterns that possess enough structure to be played through as music, and enough novelty not to make it repetitive.

It is important that the user looks at the returns' time-series and the tail exponential chart, that depicts not the tail exponential but, rather, the certain loss equivalent. If one listens to the music, and looks at these pictures one can see the interconnection between the music and the tail risk dynamics.


------------------------
PART 4: THE SIMULATION
------------------------


HOW TO START


To start the simulation you should must click first setup, then, setup-past-history, and when the program regarding setup-past-history stop, you must click go, to run the simulation.

The setup-past-history defines an initial history for the value-investors to learn.



THE MAIN USER INTERFACE


The main user interface is divided in several areas that the user can explore.

It contains the value investors’ parameters that are the same as the ones of the previous artificial financial market.

It also contains the speculators and trend followers’ parameters. For both of these agent-types the user can control the memory and the probability of strategy innovation (as long as the innovation switch is on).

The user can also control the basic parameters that allow the determination of the volatility. Namely: 

I) The decay factor that allows the determination of the exponentially weighted moving average volatility estimate;

II) The threshold that determines the conditioning event that allows the determination of the TE risk measure;

III) Since the TE is estimated according to a moving average scheme, the user can also choose the time-window for the determination of the TE, by default, the time window slider is set to 50 time periods.

The user can also determine the impact that each agent type has in the market. The sliders to do this are the value-investor-strength and the trend-follower-strength.

The weights for the determination of the logarithmic returns, as explained when we addressed the market-making mechanism, are obtained as follows:

- The weight of the value investors is set equal to the value-investor-strength
- The weight of the trend follower is set equal to (1 - value-investor-strength) * trend-follower-strength
- The weight of the speculator is set equal to (1 - value-investor-strength) * (1 - trend-follower-strength)

There is also a slider that controls for the agents that are represented at any time by the Netlogo world. The slider called board

Although all agents are trading at the same time, you are only able to see each agent type at any time, depending on the board chosen. If the board is set to equal to 0, then, you'll only see the value investors, the green ones buy, and the red ones sell. If the board is set equal to 1, you'll see the speculators buying and selling, with the same code colour. If the board is set equal to 3 you'll see the trend followers.

Finally, if you're looking at the speculator or the trend follower board and have the switch strategy-colour set to on, then, you'll see, instead of buying and selling colour codes, the colour codes represent the strategy, in the case of the speculators, and, for the trend-followers, trend-follower identity.



---------------------------------
PART 4: THINGS TO NOTICE AND TRY
---------------------------------

Try to alter the strength of each trader, the innovation probabilities and see what happens to the behaviour of the returns.

Notice the music, it reflects the tail exponential risk measure versus the returns. Can you identify any patterns in the music?

Try to classify the music played by the returns.

Notice what happens to the TE risk measure, does it show trends. Put the world next to the graph and look at what happens to the TE when the market synchronizes for more than one period, for the value investors.

Try to run the model with the strategy switched on, can you describe strategy contagion effects. 

What happens when you switch off the innovation button are the learning dynamics different?

As the market synchronizes for the value investors turn the cube around and notice the colouring of the several faces of the cube.

Change the number of agents by increasing the cube, does the overall behaviour change.


CREDITS AND REFERENCES
----------------------

We would like to thank Professor Miguel Ferreira, ISCTE Business School, my thesis coordinator, for his support and continuing interest in my research on tail risk. Professor Yasuhiro Yamai of the Bank of Japan for the important exchange of thoughts regarding tail risk, Professor Shaun Wang of SCOR which played a major role in the path taken by my MsC thesis, and, Professor Didier Sornette, of UCLA Department of Earth and Space Sciences, for the interest shown in the first artificial financial market and the important exchange of ideas regarding the first artificial financial market.

The tail exponential risk measure was introduced in the MsC thesis: 

Gonçalves, Carlos P., 2004, A Method for Tail Risk and Model pK-Tail Risk Control in (Sub)Market Risk Measurement Systems, MsC Thesis, ISCTE Business School, May.

And further developed in the papers:

Gonçalves, Carlos P.; Ferreira, Miguel A., 2004, Tail Risk and pK-Tail Risk, December 2004. Available at: http://ssrn.com/abstract=639181  (submitted to the Journal of Risk and Insurance).

Gonçalves, Carlos P., 2005, Um Método de Controlo de Risco de Cauda, in Temas em Métodos Quantitativo: Perspectivas do Cálculo Financeiro - 2005, Raul Laureano and Luis Lopes dos Santos (Ed.), Edições Sílabo, Lisboa.


To produce this new artificial financial market we based ourselves, for the market maker and the trend follower in:

Farmer, Doyne (1998). "Market, Force, Ecology, Evolution". Santa Fe Working Papers

The speculators and trend-followers learning algorithms came from the combination of genetic algorithms and from the social learning rule contained in the Netlogo model library’s model PD Basic Evolutionary:

Wilensky, U. (2002).  NetLogo PD Basic Evolutionary model.
http://ccl.northwestern.edu/netlogo/models/PDBasicEvolutionary.
Center for Connected Learning and Computer-Based Modelling,
Northwestern University, Evanston, IL.

We like this combination better than traditional Genetic Algorithms (GAs) for social systems since it is less biological and more social, with its main strength put on local social imitation, and on individual creativity (in the form of the innovation, which corresponded to mutation, in the case of GAs). It also has a more Lamarckian flavour to it, which makes it closer to human social and cultural evolution.

This model is a part of a project still under investigation and this is the first place in which it is being proposed and in which a description and overall discussion of the model is being made. Any references to this model for academic publication should refer to:

Gonçalves, Carlos Pedro (2003) Artificial Financial Market Model II - Tail Risk. http://ccl.northwestern.edu/netlogo/models/community/Artificial Financial Market Model

There are two papers under way regarding this new artificial financial market and the, forthcoming, Artificial Financial Market III - Synchronicity, featuring two risky assets and inter-asset synchronicity (and more music).

Any comments or suggestions are quite welcomed and should be addressed to cgon1@iscte.pt


FURTHER REFERENCES:

Besides the references that appear on the first artificial financial market, here are some further references:

1) Regarding the concept of tail risk:
---------------------------------------


Yamai, Y.; Yoshiba, T., 2001, Comparative Analyses of Expected Shortfall and Value at Risk (2): Expected Utility Maximization and Tail Risk, IMES discussion paper series 2001-E-14, Institute of Monetary and Economic Studies, Bank of Japan.

Yamai, Y.; Yoshiba, T., 2002a, Comparative Analyses of Expected Shortfall and Value at Risk (2): Expected Utility Maximization and Tail Risk; Monetary and Economic Studies, April, pp. 95-116.

Yamai, Y.; Yoshiba, T., 2002b, Comparative Analyses of Expected Shortfall and Value at Risk (3): Their Validity under Market Stress; Monetary and Economic Studies, October, pp. 181-238.


2) Regarding the artificial financial market:
----------------------------------------------

Some additional work done by Sornette that influenced the artificial financial market project:

Corcos, A.; Eckman, J.-P.; Malaspinas, A.; Malevergne, Y.; Sornette, D., 2002, Imitation and Contrarian Behavior: Hyperbolic Bubbles, Crashes and Chaos, Quantitative Finance 2, 264-281 (also available at http://arXiv.org/abs/cond-mat/0109410)

Zhou, W.-X. and Sornette, D., 2003, Evidence of a Worldwide Stock-Market Log-Periodic Anti-Bubble Since mid-2000, Physica A

Johansen, A.; Sornette, D., 2004, Endogenous versus Exogenous Crashes in Financial Markets, in press in "Contemporary Issues in International Finance" (Nova Science Publishers)

Sornette, D.; Gilbert, T.; Helmstetter A.; Ageon, Y., Endogenous Versus Exogenous Shocks in Complex Networks: an Empirical Test (available at http://arXiv.org/abs/cond-mat/0310135)

Sornette, D. and Zhou, W.-X., Predictability of Larger Future Changes in Complex Systems (available at http://arXiv.org/abs/cond-mat/0304601)


3) Regarding financial risk we also used:
-----------------------------------------

J.P. Morgan Bank, RiskMetrics Technical Manual, New York: J.P. Morgan Bank, 1995
@#$#@#$#@
default
true
0
Polygon -7566196 true true 150 5 40 250 150 205 260 250

ant
true
0
Polygon -7566196 true true 136 61 129 46 144 30 119 45 124 60 114 82 97 37 132 10 93 36 111 84 127 105 172 105 189 84 208 35 171 11 202 35 204 37 186 82 177 60 180 44 159 32 170 44 165 60
Polygon -7566196 true true 150 95 135 103 139 117 125 149 137 180 135 196 150 204 166 195 161 180 174 150 158 116 164 102
Polygon -7566196 true true 149 186 128 197 114 232 134 270 149 282 166 270 185 232 171 195 149 186
Polygon -7566196 true true 225 66 230 107 159 122 161 127 234 111 236 106
Polygon -7566196 true true 78 58 99 116 139 123 137 128 95 119
Polygon -7566196 true true 48 103 90 147 129 147 130 151 86 151
Polygon -7566196 true true 65 224 92 171 134 160 135 164 95 175
Polygon -7566196 true true 235 222 210 170 163 162 161 166 208 174
Polygon -7566196 true true 249 107 211 147 168 147 168 150 213 150

arrow
true
0
Polygon -7566196 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

bee
true
0
Polygon -256 true false 151 152 137 77 105 67 89 67 66 74 48 85 36 100 24 116 14 134 0 151 15 167 22 182 40 206 58 220 82 226 105 226 134 222
Polygon -16777216 true false 151 150 149 128 149 114 155 98 178 80 197 80 217 81 233 95 242 117 246 141 247 151 245 177 234 195 218 207 206 211 184 211 161 204 151 189 148 171
Polygon -7566196 true true 246 151 241 119 240 96 250 81 261 78 275 87 282 103 277 115 287 121 299 150 286 180 277 189 283 197 281 210 270 222 256 222 243 212 242 192
Polygon -16777216 true false 115 70 129 74 128 223 114 224
Polygon -16777216 true false 89 67 74 71 74 224 89 225 89 67
Polygon -16777216 true false 43 91 31 106 31 195 45 211
Line -1 false 200 144 213 70
Line -1 false 213 70 213 45
Line -1 false 214 45 203 26
Line -1 false 204 26 185 22
Line -1 false 185 22 170 25
Line -1 false 169 26 159 37
Line -1 false 159 37 156 55
Line -1 false 157 55 199 143
Line -1 false 200 141 162 227
Line -1 false 162 227 163 241
Line -1 false 163 241 171 249
Line -1 false 171 249 190 254
Line -1 false 192 253 203 248
Line -1 false 205 249 218 235
Line -1 false 218 235 200 144

bird1
false
0
Polygon -7566196 true true 2 6 2 39 270 298 297 298 299 271 187 160 279 75 276 22 100 67 31 0

bird2
false
0
Polygon -7566196 true true 2 4 33 4 298 270 298 298 272 298 155 184 117 289 61 295 61 105 0 43

boat1
false
0
Polygon -1 true false 63 162 90 207 223 207 290 162
Rectangle -6524078 true false 150 32 157 162
Polygon -16776961 true false 150 34 131 49 145 47 147 48 149 49
Polygon -7566196 true true 158 33 230 157 182 150 169 151 157 156
Polygon -7566196 true true 149 55 88 143 103 139 111 136 117 139 126 145 130 147 139 147 146 146 149 55

boat2
false
0
Polygon -1 true false 63 162 90 207 223 207 290 162
Rectangle -6524078 true false 150 32 157 162
Polygon -16776961 true false 150 34 131 49 145 47 147 48 149 49
Polygon -7566196 true true 157 54 175 79 174 96 185 102 178 112 194 124 196 131 190 139 192 146 211 151 216 154 157 154
Polygon -7566196 true true 150 74 146 91 139 99 143 114 141 123 137 126 131 129 132 139 142 136 126 142 119 147 148 147

boat3
false
0
Polygon -1 true false 63 162 90 207 223 207 290 162
Rectangle -6524078 true false 150 32 157 162
Polygon -16776961 true false 150 34 131 49 145 47 147 48 149 49
Polygon -7566196 true true 158 37 172 45 188 59 202 79 217 109 220 130 218 147 204 156 158 156 161 142 170 123 170 102 169 88 165 62
Polygon -7566196 true true 149 66 142 78 139 96 141 111 146 139 148 147 110 147 113 131 118 106 126 71

box
true
0
Polygon -7566196 true true 45 255 255 255 255 45 45 45

butterfly1
true
0
Polygon -16777216 true false 151 76 138 91 138 284 150 296 162 286 162 91
Polygon -7566196 true true 164 106 184 79 205 61 236 48 259 53 279 86 287 119 289 158 278 177 256 182 164 181
Polygon -7566196 true true 136 110 119 82 110 71 85 61 59 48 36 56 17 88 6 115 2 147 15 178 134 178
Polygon -7566196 true true 46 181 28 227 50 255 77 273 112 283 135 274 135 180
Polygon -7566196 true true 165 185 254 184 272 224 255 251 236 267 191 283 164 276
Line -7566196 true 167 47 159 82
Line -7566196 true 136 47 145 81
Circle -7566196 true true 165 45 8
Circle -7566196 true true 134 45 6
Circle -7566196 true true 133 44 7
Circle -7566196 true true 133 43 8

circle
false
0
Circle -7566196 true true 35 35 230

person
false
0
Circle -7566196 true true 155 20 63
Rectangle -7566196 true true 158 79 217 164
Polygon -7566196 true true 158 81 110 129 131 143 158 109 165 110
Polygon -7566196 true true 216 83 267 123 248 143 215 107
Polygon -7566196 true true 167 163 145 234 183 234 183 163
Polygon -7566196 true true 195 163 195 233 227 233 206 159

sheep
false
15
Rectangle -1 true true 90 75 270 225
Circle -1 true true 15 75 150
Rectangle -16777216 true false 81 225 134 286
Rectangle -16777216 true false 180 225 238 285
Circle -16777216 true false 1 88 92

spacecraft
true
0
Polygon -7566196 true true 150 0 180 135 255 255 225 240 150 180 75 240 45 255 120 135

thin-arrow
true
0
Polygon -7566196 true true 150 0 0 150 120 150 120 293 180 293 180 150 300 150

truck-down
false
0
Polygon -7566196 true true 225 30 225 270 120 270 105 210 60 180 45 30 105 60 105 30
Polygon -8716033 true false 195 75 195 120 240 120 240 75
Polygon -8716033 true false 195 225 195 180 240 180 240 225

truck-left
false
0
Polygon -7566196 true true 120 135 225 135 225 210 75 210 75 165 105 165
Polygon -8716033 true false 90 210 105 225 120 210
Polygon -8716033 true false 180 210 195 225 210 210

truck-right
false
0
Polygon -7566196 true true 180 135 75 135 75 210 225 210 225 165 195 165
Polygon -8716033 true false 210 210 195 225 180 210
Polygon -8716033 true false 120 210 105 225 90 210

turtle
true
0
Polygon -7566196 true true 138 75 162 75 165 105 225 105 225 142 195 135 195 187 225 195 225 225 195 217 195 202 105 202 105 217 75 225 75 195 105 187 105 135 75 142 75 105 135 105

wolf
false
0
Rectangle -7566196 true true 15 105 105 165
Rectangle -7566196 true true 45 90 105 105
Polygon -7566196 true true 60 90 83 44 104 90
Polygon -16777216 true false 67 90 82 59 97 89
Rectangle -1 true false 48 93 59 105
Rectangle -16777216 true false 51 96 55 101
Rectangle -16777216 true false 0 121 15 135
Rectangle -16777216 true false 15 136 60 151
Polygon -1 true false 15 136 23 149 31 136
Polygon -1 true false 30 151 37 136 43 151
Rectangle -7566196 true true 105 120 263 195
Rectangle -7566196 true true 108 195 259 201
Rectangle -7566196 true true 114 201 252 210
Rectangle -7566196 true true 120 210 243 214
Rectangle -7566196 true true 115 114 255 120
Rectangle -7566196 true true 128 108 248 114
Rectangle -7566196 true true 150 105 225 108
Rectangle -7566196 true true 132 214 155 270
Rectangle -7566196 true true 110 260 132 270
Rectangle -7566196 true true 210 214 232 270
Rectangle -7566196 true true 189 260 210 270
Line -7566196 true 263 127 281 155
Line -7566196 true 281 155 281 192

wolf-left
false
3
Polygon -6524078 true true 117 97 91 74 66 74 60 85 36 85 38 92 44 97 62 97 81 117 84 134 92 147 109 152 136 144 174 144 174 103 143 103 134 97
Polygon -6524078 true true 87 80 79 55 76 79
Polygon -6524078 true true 81 75 70 58 73 82
Polygon -6524078 true true 99 131 76 152 76 163 96 182 104 182 109 173 102 167 99 173 87 159 104 140
Polygon -6524078 true true 107 138 107 186 98 190 99 196 112 196 115 190
Polygon -6524078 true true 116 140 114 189 105 137
Rectangle -6524078 true true 109 150 114 192
Rectangle -6524078 true true 111 143 116 191
Polygon -6524078 true true 168 106 184 98 205 98 218 115 218 137 186 164 196 176 195 194 178 195 178 183 188 183 169 164 173 144
Polygon -6524078 true true 207 140 200 163 206 175 207 192 193 189 192 177 198 176 185 150
Polygon -6524078 true true 214 134 203 168 192 148
Polygon -6524078 true true 204 151 203 176 193 148
Polygon -6524078 true true 207 103 221 98 236 101 243 115 243 128 256 142 239 143 233 133 225 115 214 114

wolf-right
false
3
Polygon -6524078 true true 170 127 200 93 231 93 237 103 262 103 261 113 253 119 231 119 215 143 213 160 208 173 189 187 169 190 154 190 126 180 106 171 72 171 73 126 122 126 144 123 159 123
Polygon -6524078 true true 201 99 214 69 215 99
Polygon -6524078 true true 207 98 223 71 220 101
Polygon -6524078 true true 184 172 189 234 203 238 203 246 187 247 180 239 171 180
Polygon -6524078 true true 197 174 204 220 218 224 219 234 201 232 195 225 179 179
Polygon -6524078 true true 78 167 95 187 95 208 79 220 92 234 98 235 100 249 81 246 76 241 61 212 65 195 52 170 45 150 44 128 55 121 69 121 81 135
Polygon -6524078 true true 48 143 58 141
Polygon -6524078 true true 46 136 68 137
Polygon -6524078 true true 45 129 35 142 37 159 53 192 47 210 62 238 80 237
Line -16777216 false 74 237 59 213
Line -16777216 false 59 213 59 212
Line -16777216 false 58 211 67 192
Polygon -6524078 true true 38 138 66 149
Polygon -6524078 true true 46 128 33 120 21 118 11 123 3 138 5 160 13 178 9 192 0 199 20 196 25 179 24 161 25 148 45 140
Polygon -6524078 true true 67 122 96 126 63 144

@#$#@#$#@
NetLogo 3-D Preview 1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
