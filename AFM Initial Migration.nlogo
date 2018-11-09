patches-own [my-sentiment ;; Each trader can have a positive sentiment (+1), in which case he is 'bullish',
                          ;; that is, he beleives the market will rise or he can have a
                           ;; negative sentiment (-1) in which case he is 'bearish', that is, he beleives the market will fall.
                          ;; if the sentiment is positive the trader buys one share if it is negative he sells
                          ;; one share.
             number-of-shares ;; Number of shares that each trader has (if negative it implies that the
                              ;; trader is 'short' (we assume that there are no limits to short selling).
             opinion-vol  ;; Volatility in a trader's own interpretation of the news.
             propensity-to-sentiment-contagion ;; Propensity to be influenced by friends sentiments
                                                ;; regarding the news qualitative nature.
             base-propensity-to-sentiment-contagion
             news-sensitivity ;; Sensitivity that the traders have to the news qualitative meaning.
             indicator ;; Allows the counting of the traders.
             ]

globals [log-price
         returns
         news-qualitative-meaning  ;; There is a set of news concerning the market that reaches all traders
                                   ;; these news are attributed a qualitative meaning
         number-of-traders
         volatility-indicator
         ]

to setup
ca
ask patches [
             set number-of-shares 1 ;; Each trader starts with one unit of shares
             set opinion-vol sigma + random-float 0.1
             set news-sensitivity (random-float max-news-sensitivity)
             set base-propensity-to-sentiment-contagion (random-float max-base-propensity-to-sentiment-contagion)
             set propensity-to-sentiment-contagion base-propensity-to-sentiment-contagion
             set indicator 1
             ]
set log-price 0
end


to go
news-arrival
agent-decision
market-clearing
update-market-sentiment
compute-volatility-indicator
do-plot
end


;;;;;;;;;;;;;;;;;;;;;;;;;;
; News Arrival mechanism ;
;;;;;;;;;;;;;;;;;;;;;;;;;;
to news-arrival
ifelse (random-normal 0 1) > 0
         [set news-qualitative-meaning 1]
         [set news-qualitative-meaning -1]
end
;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;
; Agent's decision rule ;
;;;;;;;;;;;;;;;;;;;;;;;;;
; The agent's (in this case trader) sentiment is positive (+1) and he buys if
; the friends sentiment regarding the market, multiplied by the agent's propensity to be contagiated by
; the sentiment of his friends, plus the news multiplied by the agent's news sensitivity, plus a random
; term is larger than zero, otherwise, the agent's sentiment is set (-1) and the agent sells.
to agent-decision
    ask patches [
    ifelse ((propensity-to-sentiment-contagion * mean [my-sentiment] of neighbors + news-sensitivity * news-qualitative-meaning + random-normal miu opinion-vol) > 0)
                   [set my-sentiment 1
                   set number-of-shares number-of-shares + 1] ;; Buy
                   [set my-sentiment -1
                    set number-of-shares number-of-shares - 1] ;; Sell
                    ]
; If the agent's sentiment is positive the colour is set green, if he is negative it is set red.
ask patches [if my-sentiment = 1
                 [set pcolor green]
             if my-sentiment = -1
                 [set pcolor red]
                 ]
end
;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Market clearing mechanism ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to market-clearing
set log-price (log-price + returns)
  set number-of-traders sum [indicator] of patches
set returns sum [my-sentiment] of patches / number-of-traders
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
                [set propensity-to-sentiment-contagion base-propensity-to-sentiment-contagion + returns]
             if (returns > 0) and (news-qualitative-meaning < 0)
                [set propensity-to-sentiment-contagion base-propensity-to-sentiment-contagion - returns]
             if (returns < 0) and (news-qualitative-meaning < 0)
                [set propensity-to-sentiment-contagion base-propensity-to-sentiment-contagion - returns]
             if (returns < 0) and (news-qualitative-meaning > 0)
                [set propensity-to-sentiment-contagion base-propensity-to-sentiment-contagion + returns]

                ]
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;
; Deviations to EMH ;
;;;;;;;;;;;;;;;;;;;;;;;;


to compute-volatility-indicator
set volatility-indicator abs(returns)
end

;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

to do-plot
set-current-plot "Log-price"
set-current-plot-pen "log-price"
plot log-price
set-current-plot "Returns"
set-current-plot-pen "returns"
plot returns
set-current-plot "Volatility"
set-current-plot-pen "volatility"
plot volatility-indicator

end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@#$#@#$#@
GRAPHICS-WINDOW
1
285
200
485
-1
-1
1.9
1
10
1
1
1
0
1
1
1
-50
50
-50
50
0
0
1
ticks
30.0

BUTTON
11
15
74
48
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
95
17
158
50
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
20
69
192
102
max-news-sensitivity
max-news-sensitivity
0
1
0.31
0.01
1
NIL
HORIZONTAL

SLIDER
24
125
196
158
miu
miu
-1
1
0.25
0.01
1
NIL
HORIZONTAL

SLIDER
28
183
200
216
sigma
sigma
0
1
0.727
0.0010
1
NIL
HORIZONTAL

SLIDER
14
226
198
259
max-base-propensity-to-sentiment-contagion
max-base-propensity-to-sentiment-contagion
0
1
0.27
0.01
1
NIL
HORIZONTAL

PLOT
256
15
649
165
Log-price
time
log-price
0.0
1000.0
0.0
10.0
true
false
"" ""
PENS
"log-price" 1.0 0 -13345367 true "" "plot count turtles"

PLOT
255
174
650
324
Returns
time
returns
0.0
1000.0
-0.05
0.05
true
false
"" ""
PENS
"returns" 1.0 0 -955883 true "" "plot count turtles"

PLOT
272
373
472
523
Volatility
time
volatility
0.0
1000.0
0.0
1.0
true
false
"" ""
PENS
"volatility" 1.0 0 -8630108 true "" "plot count turtles"

@#$#@#$#@
## WHAT IS IT?

This is a model of an artificial financial market with heterogeneous boundedly rational agents that are influenced by the sentiment of their most close colleagues regarding the future evolution of the market.

The model is capable of generating the stylized facts of the real financial markets, specifically: excess volatility in the logarithmic returns, clustered volatility (characteristic of the well known GARCH signatures), bubbles and crashes.

The main influences behind this model were Vaga's coherent market hypothesis (Vaga, 1990) and Johansen, Ledoit, Sornette's model (Johansen et. al., 2002, Sornette, 2003), from now on denoted by JLS.

Our model may also be of interest to areas outside of finance, areas like, for instance, the study of social influence, opinion making and political decision.

Given a somewhat greater complexity that this model has, relative to its ancestor (herding), the usual presentation is changed a bit, the information that is presented next will allow the user to take a larger advantage from the model and the model's main conclusions, and allow him/her to put into perspective what is being done and what is intended.

An added reason for a greater completeness in the presentation to the model is that it is essentially new. Despite its background being strongly linked to the JLS model there are new assumptions that were not assumed by Johansen, Ledoit and Sornette (Johansen et. al., 2002, Sornette, 2003), and that are not contained in the JLS model. One of the major differences between our model and these authors' corresponding model, is that the JLS model proposed an explanation for the crashes based on imitative behaviour of noise traders.

Our model moves away from this type of traders by basing itself on different cognitive assumptions. Specifically, in this model we brake away with the usual dichotomies assumed, like rational investors/noise traders, informed traders/uninformed traders. And assume that all agents are informed, rational, but only boundedly so, and heterogeneous. This leads to several modifications to the JLS model, which we discuss in this presentation.

Another novelty of the model relative to JLS, is that it proposes an endogenous dynamics for the coupling parameter. The coupling parameter is no longer the same for everyone, it differs from individual to individual, and individual psychology, mass behaviour and news play a non-trivial role in its dynamics. The result is that, in most instances of the model's parameters, the price dynamics and returns dynamics closely approximate that of the real markets. This makes the model more complex than herding.

Given this novelty and added complexity, it was felt that to fully convey the most important contents of the model and for the user to gain a more thorough grasp of it, a more complete introduction to the model is needed, to that end the presentation was divided in the following points:

1- The model's theoretic foundations - this gives the basic theoretic background behind the model, in this part we just give a brief overview of the two main hypothesis that are at stake here and introduce the main assumptions used for the construction of the model.

2- The model's formalization - this part gives the main model's formalization, it is essential, for criticisms and adding of new features, that this formalization is made known and not just inferred from the code.

3- Guide to the user - this contains information regarding the model's interface and suggestions to the user.

4 - Main findings - some findings that can be reproduced by the user (what to notice and things to try, the usual sections of the models presentation pages).


## 1) THE MODEL'S THEORETIC FOUNDATIONS: OVERVIEW OF THE EFFICIENT MARKET HYPOTHESIS AND COHERENT MARKET HYPOTHESIS

According to the Efficient Market Hypothesis (EMH) the prices reflect the whole of the information regarding the value of any asset traded in a financial market. The price of the asset is, thus, never above, nor below its intrinsic value. The EMH, closely related to neoclassical economics, was, and still is, the main hypothesis of the mainstream academic finance, however, its strength has been largely weakened, since its beginnings in the 1960s.

Evidence concerning deviations to this hypothesis' predictions increased as larger amounts of data became available and as the statistical analysis techniques became more sophisticated.

Asset prices seem to be more volatile than was predicted by the theory, crashes and speculative bubbles happen with a larger frequency than was expected, the well known day of the week and day of the month effects, the small firm effect, and many more.

In this model, we concentrate on the volatility aspect. This aspect is particularly important for issues like financial markets risk measurement and risk management, which are bearing a considerable larger weight on the most recent financial literature (Jorion, 1997).

Before we address these issues we dwell a little longer, on the subject of the theoretical foundations of the EMH, which we criticize in our model.

Schleifer (2000) identifies three theoretical arguments in which the case for EMH rests on, these are (Schleifer, 2000, p.2):

"(...) investors are assumed to be rational and hence to value securities rationally (...) to the extent that some investors are not rational, their trades are random and therefore cancel each other out without affecting prices (...) to the extent that investors are irrational in similar ways, they are met in the market by rational arbitrageurs who eliminate their influence on prices."

It is these arguments that our model puts into question. Indeed, instead of assuming the usual dichotomy rational/irrational, or rational investor/noise trader, we consider that all individuals are boundedly rational and heterogeneous, this means that they take into account the information that comes to the market, however, that information reflects itself in their expectations regarding the market in a different way than it would were they the homogeneous and fully rational agents of the EMH.

The main aspect of our model is the sentiment that individuals form concerning the nature of the news that arrives and concerning its implications to the future evolution of the prices. This sentiment regarding the market is felt by the individual in such a way that he is lead to the decision to buy or sell based on this sentiment, furthermore, this sentiment is either good in the sense that the individual feels that the news are good and offer good prospects of a future increase in the value of his/her investment, or the sentiment is bad, in which case the individual feels that the news are bad, and thus, the value of his/her investment will decrease.

If individuals were the agents of the EMH the sentiment they would form would reflect only the news. However, in our model, of heterogeneous and boundedly rational agents, to this sentiment contribute not only the news themselves, but also the verbalized or someway transmitted sentiments of the individual's closest colleagues, and an own idiosyncratic aspect of the individual which influences his interpretation of both the news and his friends sentiments, thus, these elements together lead to the sentiment, that the individual is aware of, and that leads to the final decision to buy or sell.

This is incorporated into a spin-glass type model in which the propensity to be contagiated by the sentiments of others increases if the nature of the news are confirmed by market movement in the same direction (good(bad) news and price increase(decrease)), and decreases if the nature of the news is in the direction contrary to that of the market (good(bad) news and price decrease (increase)).

The result of the interplay of these forces is for some parameter windows, excess and clustered volatility, manias and panics, bubbles and crashes.

These are all phenomena present in the actual financial markets and that constitute evidence against the EMH (Shleifer, 2000).

Note however, that investors are not irrational and that new information is, at least in part reflected in the price. Also, this new information, along with the macroscopic state of the system, are the elements that influence the dynamics of the coupling parameter.

The nature of the model brings it close to the Coherent Market Hypothesis (CMH), introduced by Vaga (1990) and to the synergetics approach to complexity. Vaga (1990) introduced the CMH basing himself on Haken's synergetics and on the work developed by Callen and Shapero on the theory of social imitation (Callen, Shapero, 1974). Some of the assumptions made by Vaga are common to ours, and some of the statements of Vaga also apply in our case, namely, in both Vaga and in this model "(...) the stock market is an "open" system (...)" (Vaga, 1990, p.40) that requires a "(...) continuous flow of money to maintain a transition from a disordered to a more ordered state (...)" (Vaga, 1990, p.40). The present model is also based on spin-glasses, as Vaga's was. And the market also passes from disorganized states to organized states and, from times to times, the market enters in coherent bullish or coherent bearish phases. There are also random walk phases, in which the market acts in a more or less disorganized fashion, and there is a whole range of behaviours in between. The connections between the states of the model's markets and Vaga's work are, however, still being researched upon, and the connection between the CMH, and the model still needs to be worked on (this is a subject under investigation).

The main basis of the model is the work of Sornette (2003) and Johansen, Sornette and Ledoit's (2002) on the dynamics of herding and on market crashes. The JLS model was the subject of the previous Netlogo's model herding. The main differences between the model that is now presented and the JLS have already been introduced and will be returned to as we advance in the construction of the model.

This finishes the main references, we now discuss the model.

## 2) THE MODEL

At each time step new information arrives to the market as a signal I(t). One of the results of the EMH is that after we discount the expected price using a rate that reflects the investment's time horizon and the risk profile (actually in finance one uses transformed probabilities, the so-called risk neutral probabilities, and then we can use the risk free rate for the same horizon to obtain the present value of the expected price, however, this is a rather technical subject so we do not dwell on it any longer in this presentation), in this sense, after discounting, the expected return on the asset should be null (the price becomes driftless). This implies that the information that arrives into the market, after discounting, should not be biased towards a positive or a negative sense, since we are interpreting price as the expected value after discounting and consider the information in these terms also. So, we assume that the information is a driftless random quantity with a probability distribution symmetric around zero, we take the information signal to be normally distributed with mean 0 and standard deviation of 1 (another justification for this symmetry could be that for a small enough time period the information is more or less driftless in its nature).

A qualitative meaning is given to the information, this meaning is taken in binary terms as either being good (+1) or bad (-1), in this sense we have, at time t:

(1): I(t)~N(0,1)
(2): Q(t)=1 if I(t)>0, Q(t)=-1 otherwise

I(t) - New Information (news for short)
Q(t) - Qualitative meaning						

We now construct the sentiment formation rule, which forms the basis of the traders decisions. To define the sentiment formation rule we introduce three assumptions:

Assumption 1) Individuals are boundedly rational.
Assumption 2) Individuals are heterogeneous.
Assumption 3) Individuals are open to the sentiments of their closest colleagues regarding the qualitative meaning of the information.

The fact that individuals are boundedly rational leads to limits in the interpretation of the information. These limits, in our case, need not come necessarily from different accesses to information, indeed all traders are informed traders, these limits are considered to be intrinsic to the individual. The reason for this, is that, unlike the neoclassical agent that knew all in all of its dimensions, we assume that agents need to cognitively interpret their experiences, they form models of the world and of their position in the world, and these models differ from individual to individual (assumption 3). Indeed the knowledge and experience, the background of each trader is different, so that they interpret the information differently, and they have to learn about the world, to make sense of it, and of their position in it (this is close to Arthur, Durlauf and Lane's view (Arthur, et. al., 1997, p.5)). This separates our agents from noise traders (which are present in the JLS model) and from the neoclassical agent.

In this sense, the sentiment regarding the market is formed differently for each trader and each reacts differently to the information. The new information, however, is not the only external force acting at the agent level, we have to take into account the possibility of social communication and of social transmission of sentiments regarding the qualitative meaning of the information. In this sense, as in the JLS model, we assume that there is some sensitivity of the individual to the sentiments of his/hers closest colleagues in the trader's network of relations.

This openness of the individual to others is a strategy of rationality expansion, given the limits of the individual's rationality.

We need to consider a topology for this network, so as an extra assumption we state:

Assumption 4) (working assumption): The network of traders is a bidimensional lattice (the Netlogo's world) and each trader is connected to his/hers four nearest neighbours, and periodic boundary conditions are assumed.

This network topology is the same as the one assumed in the JLS model.

Taking all these four assumptions the JLS model's rule (see herding model) is modified into the following rule (the sign function takes the value +1 when the argument is positive and -1 when the argument is negative):

(3): Si(t)=sign(Ki*NSi(t)+nsi*Q(t)+ei(t))

Ki - Propensity of the trader i to be contagiated with the friends sentiment.

NSi(t) - The sum of the trader i's friends sentiments.

nsi - the sensitivity of the trader i to the news qualitative meaning.

ei(t) - a random term that accounts for each individual's own interpretation of the news (called the idiosyncratic term (Sornette, 2003)), we take it to be normally distributed around zero and with standard-deviation to be controlled by the user.

Si(t) - trader i's sentiment regarding the information, if it is good (bullish) the trader buys if it is bad (bearish) the trader sells.

Note that each of the elements that form the argument of the sign function differ from trader to trader, except the news qualitative meaning which is a common component.

We have already given the trader's decision rule in the explanation of Si(t), so now we just have to define the price formation rule, we take the logarithm of the price to be the sum of the previous period price plus the sum of the traders sentiment (which coincides with the traders position) divided by the number of traders.

The returns (these are in fact logarithmic returns) are the difference between the present log-price and the previous log-price, which is nothing but the sum of the traders sentiment divided by the number of traders, this variable has also been previously called 'groupthink' (Ponzi, Aizawa, 1999).

Now, we define a cognitive rule for the dynamics of the propensity to be contagiated by the sentiments of others. We assume that individuals have a base propensity to be contagiated by the sentiments of others, and that, if a good(bad) news is confirmed by a market movement in the same direction, then the individual's propensity to contagion is set equal to his/hers base propensity plus(less) an amount equal value of to the returns, otherwise the propensity to contagion is set equal to the base propensity less(plus) an amount equal to the value of the returns. The choice of the returns for the amount to be added or subtracted has to do with the fact that this is an indicator of the average aggregate state of the market, and it is related to the degree of herding, as we shall see later on in this presentation.

Let us give a basic intuition for this rule. Assume a pessimistic scenario (an optimistic would also serve as an example), more specifically, assume that a bad news arrives and that this bad news is confirmed by a market movement in the same direction. The market only confirms the bad news if there is a larger number of agents with a negative sentiment (bearish) relative to those with a positive sentiment (bullish), so that the aggregate sentiment is bearish, then, the traders become more sensitive to the others sentiments, and the bad sentiment catches on to the next period. This results in a large loss, if the news are good in the next period and the returns fall, and the system is near criticality, then, there was an under-reaction phenomenon, the herding diminishes, and if the system is near criticality, the period that follows shows disorganization in the market and a correction movement. This is responsible for most of the volatility phenomena in the financial markets, as we shall see.


This finishes the description of the model. We now provide a guide to the user.

## USER GUIDE

There are four sliders that the user can control, these are:

- miu
- sigma
- max-news-sensitivity
- max-base-sentiment-contagion

The first two sliders are related to the idiosyncratic term's dynamics. The miu is usually set to zero, which means that individuals are neither biased towards a negative nor towards a positive sentiment.

The sigma slider is a reference standard-deviation, the standard deviation associated with each trader's idiosyncratic term is set to this value plus a random number between 0 and 0.1, so this slider controls the minimum standard-deviation for each trader's idiosyncratic term. 

Each trader's sensitivity to the new information is set to a random number between 0 and the max-news-sensitivity. Each trader's base sentiment contagion is also set to a random number between 0 and the max-base-sentiment-contagion.

These parameters are set at the beginning of the simulation and remain fixed throughout the rest of the simulation. Different dynamics emerge for different combinations of these parameters, for some of these parameters the markets present a dynamics very close to the one of real financial markets.

Besides the sliders there are three charts, the first is a chart of the logarithm of the price, the second a chart of the logarithm of the returns, the third is a volatility indicator. We explain each of these in turn.

The main information that can be obtained from the logarithm of the price chart is information regarding bubbles and crashes and, more importantly, states of the market that were identified by Vaga, you can at least identify three: the random walk state; the coherent bull markets state, the coherent bearish market state. These are the most visible in the chart, other patterns are under investigation but can only be identified after a statistical analysis.

The second chart is perhaps one of the most important, since for a range of parameters, it shows the dynamics usually present in the actual financial markets, like excess volatility, clusters of volatility, jumps, successive jumps, correctional movements, all evidence that, following Shleifer (2000), goes against the EMH.

The third chart is the representation of a volatility indicator, specifically, the absolute returns. This indicator has been considered to be a more accurate measure of the volatility process than the squared returns (Guillaume, Dominique in Trippi, 1995, Ding, Granger, Engle, 1993). The indicator serves, also, an important purpose, and the choice of this indicator was not arbitrary as will be explained in the main findings section.

The last item of the interface we need to discuss (and, perhaps, the most immediate to attention) is the Netlogo's world, the patches represent the agents, and their colour is set green if their sentiment is good (bullish) and red if their sentiment is bad (bearish). The world also plays an important role in the main findings.

## A SUGGESTION FOR A FIRST RUN OF THE SIMULATION

From the simulations made it was possible to identify various sets of combinations of parameters that closely capture the dynamics of the true financial markets. The initial parameters were set to one of these combinations. So for a first simulation my suggestion is that the user just turns on the go button and whatches the dynamics unfolding. The similarities with the actual markets become visible more or less from the start, however, it is only after a while that the series becomes indistinguishable from what one is used to see in an actual market.

## MAIN FINDINGS

We divide this section in three parts:

A - Herding behaviour
B - Deviations to EMH
C - Why do bubbles and crashes happen?

A) HERDING BEHAVIOUR

There is a statement in Vaga's article that this model puts into question, this statement is: "As Charles Mackay observed in the 19th century: "Men it has well been said, think in herds; it will be seen that they go mad in herds, while they recover their senses slowly and one by one."(...)" (Vaga, 1990, p.40).

The part of the sentence that is put into question is the rate at which 'men recover their senses' and the rate at which they 'go mad', these rates are only slow if men (in this case traders) 'go mad' for a long enough period.

Indeed, contrary to what is usually expected, our model gives rise to herding phenomena much more often than might be thought, indeed the market undergoes constant phase transitions from disorganized states to highly organized states, however, the permanence in each state is, most of the time very rapid, but, from time to time organized states, of highly polarized market sentiment maintain themselves for more than one time step. This can be seen by looking at the dynamics in the Netlogo's world.

The coupling parameter (which we called propensity to contagion), thus, does not follow the slow rate that was expected, it is, most of the time, rather fast in its dynamics, this is what causes volatility clustering, jumps followed by corrections, and so on. All phenomena that we discuss now.

This type of dynamics is present in various combinations of parameters, these combinations are still under investigation, however, for a high volatility in the individual's idiosyncratic signal this window is more strongly present for a maximum news sensitivity between 17 and 30 and the same for the maximum base sentiment contagion, for these two parameters this is especially true in the range above or equal to 19.

Note, also that a higher maximum possible news sensitivity, still in the range of behaviours that replicate the market's true behaviour, leads to more frequent and more extreme herding behaviours and to higher volatility.

If more precision is imposed in the individual's idiosyncratic signal, the result is that these dynamics can be caught better, for smaller values of the maximum news sensitivity.

The diversity of the dynamics is great and more parameters combinations need to be tried, though.

B) DEVIATIONS TO EMH

The main deviation to EMH we proposed to investigate here is the volatility phenomena. Indeed, if the markets were efficient, volatility would not change with time, one should not find this evidence of jumps, clustered volatility (that is, periods of high volatility followed by periods of rather mild variations).

What our model shows is that it is possible to obtain this phenomena if we relax the rationality and homogeneity assumptions.

Now, the model also allows the understanding of a mechanism behind the volatility phenomena. Indeed, the volatility clusters and the jumps come from the fast phase transitions occurring in agents herding behaviour.

When the market is in a disorganized state, there are mild fluctuations in the prices, however, as the news and the market movements follow in the same direction and the returns become larger, the market becomes polarized in its sentiment, passing the critical point towards an organized state, this creates a peak in the returns, however, if the news becomes contrary to the market movement, and the coupling is still close to the critical point, the market undergoes a phase transition and passes to a disorganized state, leading to a correction movement, this can mark the beginning of a new phase of low volatility, however, if there is another phase transition while the correction movement is taking place, the market becomes polarized again and the movement is amplified into another jump in the opposite direction of the first jump. This dynamics of fast phase transitions generates sequences of jumps of different amplitudes marking phases of highly volatile price behaviour, and also generates sequences of small variations, marking the phases of low volatility.

Therefore, the basic explanation for the volatility phenomenon, according to our model, is the dynamics of herding, this dynamics is dependent on a number of factors, these are, the level of sensitivity to the qualitative nature of the news, that is fixed throughout the simulation, the direction of the market movement relative to the nature of the news and the level of the returns. These factors (with the exception of the nature of the news and the news sensitivity) are inter-related.

The link between herding and volatility can be seen more explicitly if we take into account the last chart, which represents the absolute logarithmic returns. For the range of parameters that most closely capture the financial market's dynamics. This chart captures well the bursts of volatility, and most of the phenomena that are visible in the returns chart, however, it also measures something else, the percentage of polarization in the market sentiment.

Indeed, note that from the construction of the returns, the smaller the herding, the smaller are the returns, be they positive or negative, on the other hand, the higher the herding, the larger are the returns. So the absolute returns are large, when herding is large and small when herding is small. The maximum herding would be everyone sharing the same sentiment, in this case the absolute returns would be one. Therefore, it is a rough measure of herding, however, this is not completely accurate, since it is possible to have a high level of herding, but a rough equilibrium in group of individuals sharing the two possible sentiments, which would still lead to a small return level. Therefore, albeit being closely connected to herding, it measures more the herding with polarization phenomenon. If the herding is accompanied by a transition to a dominant sentiment, then the absolute returns become large, and the returns jump (either up or down).

Therefore, our model shows that the volatility phenomena in actual markets may emerge as a consequence of deviations to EMH, and that it can be a consequence of the dynamics of herding.

We now address the problem of the crashes and bubbles.

C) WHY DO BUBBLES AND CRASHES HAPPEN?

The answer follows from Johansen, Ledoit and Sornette (2002) and Sornette (2003): herding behaviour. However, the mechanism in the case of our model is a bit more complicated than that, because the crashes in our case happen in very specific situations, in which the market sentiment undergoes a phase transition towards an organized state and more or less plunges into that state, and the state lasts for more than one time step leading to large drops in prices and a sequence of drawdowns. The dynamics of phase transition slows down a bit in this case, and the reasons for this are still being researched upon.

The bubbles and crashes, thus, happen in periods in which the market sentiment is in an organized state for more than one period. If the new information goes in the direction contrary to the one of the crash, there may be a transition towards a disorganized state, however, this transition usually leads to small returns which may either precede a random walk period or a new large drop in prices. The phase transition is thus insufficient for a mechanism in which the whole price goes back to its previous level at once.

Bubbles and crashes remain, nonetheless outliers in our model (as it should be).


## CREDITS AND REFERENCES

Arthur, W. B., S. N. Durlauf, D. Lane (1997). "The Economy as an Evolving Complex System II". Addison-Wesley.
Callen, E., D. Shapero (1974). "A Theory of Social Imitation". Physics Today 27, No.7
Farmer, Doyne (1998). "Market, Force, Ecology, Evolution". Santa Fe Working Papers
Guillaume, Dominique. "A Low-Dimensional Fractal Attractor in the Foreign-Exchange Markets" in Trippi (1995). "Chaos and Nonlinear Dynamics in the Financial Markets". IRWIN.
Johansen, Anders, O. Ledoit, D. Sornette (2002). Crashes as Critical Points. http://arXiv:cond-mat/9810071.
Jorion, Philippe (1997). "Value at Risk". IRWIN.
Peters, Edgar E. (1996). "Chaos and Order in the Capital Markets". John Wiley & Sons.
Ponzi, A., Y. Aizawa (1999). "Criticality and Punctuated Equilibrium in a Spin System Model of a Financial Market". http://arXiv:cond-mat/9911004.
Shleifer, Andrei (2000). "Inneficient Markets, An Introduction to Behavioral Finance". Oxford University Press.
Sornette, Didier (2003). Critical Market Crashes. http://arXiv:cond-mat/0301543
Vaga, Tonis. "The Coherent Market Hypothesis". Financial Analysts Journal, November/December, 1990.
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
NetLogo 6.0.2
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
