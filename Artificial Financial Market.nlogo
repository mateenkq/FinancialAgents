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
             set opinion-vol sigma + random-int-or-float 0.1
             set news-sensitivity (random-int-or-float max-news-sensitivity)
             set base-propensity-to-sentiment-contagion (random-int-or-float max-base-propensity-to-sentiment-contagion)
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
                ifelse ((propensity-to-sentiment-contagion * nsum4 (my-sentiment) + news-sensitivity * news-qualitative-meaning + random-normal miu opinion-vol) > 0)
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
set number-of-traders sum values-from patches [indicator]
set returns sum values-from patches [my-sentiment] / number-of-traders
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
24
135
337
469
50
50
3.0
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

CC-WINDOW
5
691
879
786
Command Center
0

BUTTON
160
13
232
46
setup
setup
NIL
1
T
OBSERVER
T
NIL

BUTTON
252
13
315
46
go
go
T
1
T
OBSERVER
T
NIL

SLIDER
331
10
423
43
miu
miu
-1
1
0.25
0.01
1
NIL

SLIDER
441
10
533
43
sigma
sigma
0
1
0.727
0.0010
1
NIL

PLOT
357
339
860
486
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
"Returns" 1.0 0 -955883 true

SLIDER
164
52
508
85
max-news-sensitivity
max-news-sensitivity
0
1
0.31
0.01
1
NIL

PLOT
357
164
859
314
Log-price
time
log-price
0.0
1000.0
0.0
10.0
true
true
PENS
"log-price" 1.0 0 -13345367 true

PLOT
355
505
870
677
Volatility
time
volatility
0.0
1000.0
0.0
1.0
true
true
PENS
"volatility" 1.0 0 -8630108 true

TEXTBOX
578
45
813
115
(BELOW) PLOTS CONCERNING MARKET BEHAVIOUR AND DEVIATIONS TO EFFICIENCY MARKET HYPOTHESIS (EMH)

SLIDER
164
97
505
130
max-base-propensity-to-sentiment-contagion
max-base-propensity-to-sentiment-contagion
0
1
0.25
0.01
1
NIL

@#$#@#$#@
WHAT IS IT?
-----------
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

-------------------------------------
1) THE MODEL'S THEORETIC FOUNDATIONS
-------------------------------------

OVERVIEW OF THE EFFICIENT MARKET HYPOTHESIS AND COHERENT MARKET HYPOTHESIS
-------------------------------------------------------------------------

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
 
-------------
2) THE MODEL
-------------

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

------------------
GUIDE TO THE USER
------------------

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

A SUGGESTION FOR A FIRST RUN OF THE SIMULATION
-----------------------------------------------

From the simulations made it was possible to identify various sets of combinations of parameters that closely capture the dynamics of the true financial markets. The initial parameters were set to one of these combinations. So for a first simulation my suggestion is that the user just turns on the go button and whatches the dynamics unfolding. The similarities with the actual markets become visible more or less from the start, however, it is only after a while that the series becomes indistinguishable from what one is used to see in an actual market.

--------------
MAIN FINDINGS
--------------

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



CREDITS AND REFERENCES
----------------------

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

To know more about Haken's synergetics consult the website http://www.theo1.physik.uni-stuttgart.de/en/arbeitsgruppen/


This model is still under investigation and this is the first place in which it is being proposed and in which a description and overall discussion of the model is being made.

Any references to this model for academic publication should refer to: Carlos Pedro Gonçalves (2003) Artificial Financial Market Model. http://ccl.northwestern.edu/netlogo/models/community/Artificial Financial Market Model
This is the website for the Netlogo user community models, and I stress that this model expresses my views and not necessarily those of the community nor those of the responsible for the Netlogo program, any mistakes or possible flaws are, therefore, of my entire responsibility.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

link
true
0
Line -7500403 true 150 0 150 300

link direction
true
0
Line -7500403 true 150 150 30 225
Line -7500403 true 150 150 270 225

ant
true
0
Polygon -7500403 true true 136 61 129 46 144 30 119 45 124 60 114 82 97 37 132 10 93 36 111 84 127 105 172 105 189 84 208 35 171 11 202 35 204 37 186 82 177 60 180 44 159 32 170 44 165 60
Polygon -7500403 true true 150 95 135 103 139 117 125 149 137 180 135 196 150 204 166 195 161 180 174 150 158 116 164 102
Polygon -7500403 true true 149 186 128 197 114 232 134 270 149 282 166 270 185 232 171 195 149 186
Polygon -7500403 true true 225 66 230 107 159 122 161 127 234 111 236 106
Polygon -7500403 true true 78 58 99 116 139 123 137 128 95 119
Polygon -7500403 true true 48 103 90 147 129 147 130 151 86 151
Polygon -7500403 true true 65 224 92 171 134 160 135 164 95 175
Polygon -7500403 true true 235 222 210 170 163 162 161 166 208 174
Polygon -7500403 true true 249 107 211 147 168 147 168 150 213 150

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

bee
true
0
Polygon -1184463 true false 151 152 137 77 105 67 89 67 66 74 48 85 36 100 24 116 14 134 0 151 15 167 22 182 40 206 58 220 82 226 105 226 134 222
Polygon -16777216 true false 151 150 149 128 149 114 155 98 178 80 197 80 217 81 233 95 242 117 246 141 247 151 245 177 234 195 218 207 206 211 184 211 161 204 151 189 148 171
Polygon -7500403 true true 246 151 241 119 240 96 250 81 261 78 275 87 282 103 277 115 287 121 299 150 286 180 277 189 283 197 281 210 270 222 256 222 243 212 242 192
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
Polygon -7500403 true true 2 6 2 39 270 298 297 298 299 271 187 160 279 75 276 22 100 67 31 0

bird2
false
0
Polygon -7500403 true true 2 4 33 4 298 270 298 298 272 298 155 184 117 289 61 295 61 105 0 43

boat1
false
0
Polygon -1 true false 63 162 90 207 223 207 290 162
Rectangle -6459832 true false 150 32 157 162
Polygon -13345367 true false 150 34 131 49 145 47 147 48 149 49
Polygon -7500403 true true 158 33 230 157 182 150 169 151 157 156
Polygon -7500403 true true 149 55 88 143 103 139 111 136 117 139 126 145 130 147 139 147 146 146 149 55

boat2
false
0
Polygon -1 true false 63 162 90 207 223 207 290 162
Rectangle -6459832 true false 150 32 157 162
Polygon -13345367 true false 150 34 131 49 145 47 147 48 149 49
Polygon -7500403 true true 157 54 175 79 174 96 185 102 178 112 194 124 196 131 190 139 192 146 211 151 216 154 157 154
Polygon -7500403 true true 150 74 146 91 139 99 143 114 141 123 137 126 131 129 132 139 142 136 126 142 119 147 148 147

boat3
false
0
Polygon -1 true false 63 162 90 207 223 207 290 162
Rectangle -6459832 true false 150 32 157 162
Polygon -13345367 true false 150 34 131 49 145 47 147 48 149 49
Polygon -7500403 true true 158 37 172 45 188 59 202 79 217 109 220 130 218 147 204 156 158 156 161 142 170 123 170 102 169 88 165 62
Polygon -7500403 true true 149 66 142 78 139 96 141 111 146 139 148 147 110 147 113 131 118 106 126 71

box
true
0
Polygon -7500403 true true 45 255 255 255 255 45 45 45

butterfly1
true
0
Polygon -16777216 true false 151 76 138 91 138 284 150 296 162 286 162 91
Polygon -7500403 true true 164 106 184 79 205 61 236 48 259 53 279 86 287 119 289 158 278 177 256 182 164 181
Polygon -7500403 true true 136 110 119 82 110 71 85 61 59 48 36 56 17 88 6 115 2 147 15 178 134 178
Polygon -7500403 true true 46 181 28 227 50 255 77 273 112 283 135 274 135 180
Polygon -7500403 true true 165 185 254 184 272 224 255 251 236 267 191 283 164 276
Line -7500403 true 167 47 159 82
Line -7500403 true 136 47 145 81
Circle -7500403 true true 165 45 8
Circle -7500403 true true 134 45 6
Circle -7500403 true true 133 44 7
Circle -7500403 true true 133 43 8

circle
false
0
Circle -7500403 true true 35 35 230

person
false
0
Circle -7500403 true true 155 20 63
Rectangle -7500403 true true 158 79 217 164
Polygon -7500403 true true 158 81 110 129 131 143 158 109 165 110
Polygon -7500403 true true 216 83 267 123 248 143 215 107
Polygon -7500403 true true 167 163 145 234 183 234 183 163
Polygon -7500403 true true 195 163 195 233 227 233 206 159

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
Polygon -7500403 true true 150 0 180 135 255 255 225 240 150 180 75 240 45 255 120 135

thin-arrow
true
0
Polygon -7500403 true true 150 0 0 150 120 150 120 293 180 293 180 150 300 150

truck-down
false
0
Polygon -7500403 true true 225 30 225 270 120 270 105 210 60 180 45 30 105 60 105 30
Polygon -8630108 true false 195 75 195 120 240 120 240 75
Polygon -8630108 true false 195 225 195 180 240 180 240 225

truck-left
false
0
Polygon -7500403 true true 120 135 225 135 225 210 75 210 75 165 105 165
Polygon -8630108 true false 90 210 105 225 120 210
Polygon -8630108 true false 180 210 195 225 210 210

truck-right
false
0
Polygon -7500403 true true 180 135 75 135 75 210 225 210 225 165 195 165
Polygon -8630108 true false 210 210 195 225 180 210
Polygon -8630108 true false 120 210 105 225 90 210

turtle
true
0
Polygon -7500403 true true 138 75 162 75 165 105 225 105 225 142 195 135 195 187 225 195 225 225 195 217 195 202 105 202 105 217 75 225 75 195 105 187 105 135 75 142 75 105 135 105

wolf
false
0
Rectangle -7500403 true true 15 105 105 165
Rectangle -7500403 true true 45 90 105 105
Polygon -7500403 true true 60 90 83 44 104 90
Polygon -16777216 true false 67 90 82 59 97 89
Rectangle -1 true false 48 93 59 105
Rectangle -16777216 true false 51 96 55 101
Rectangle -16777216 true false 0 121 15 135
Rectangle -16777216 true false 15 136 60 151
Polygon -1 true false 15 136 23 149 31 136
Polygon -1 true false 30 151 37 136 43 151
Rectangle -7500403 true true 105 120 263 195
Rectangle -7500403 true true 108 195 259 201
Rectangle -7500403 true true 114 201 252 210
Rectangle -7500403 true true 120 210 243 214
Rectangle -7500403 true true 115 114 255 120
Rectangle -7500403 true true 128 108 248 114
Rectangle -7500403 true true 150 105 225 108
Rectangle -7500403 true true 132 214 155 270
Rectangle -7500403 true true 110 260 132 270
Rectangle -7500403 true true 210 214 232 270
Rectangle -7500403 true true 189 260 210 270
Line -7500403 true 263 127 281 155
Line -7500403 true 281 155 281 192

wolf-left
false
3
Polygon -6459832 true true 117 97 91 74 66 74 60 85 36 85 38 92 44 97 62 97 81 117 84 134 92 147 109 152 136 144 174 144 174 103 143 103 134 97
Polygon -6459832 true true 87 80 79 55 76 79
Polygon -6459832 true true 81 75 70 58 73 82
Polygon -6459832 true true 99 131 76 152 76 163 96 182 104 182 109 173 102 167 99 173 87 159 104 140
Polygon -6459832 true true 107 138 107 186 98 190 99 196 112 196 115 190
Polygon -6459832 true true 116 140 114 189 105 137
Rectangle -6459832 true true 109 150 114 192
Rectangle -6459832 true true 111 143 116 191
Polygon -6459832 true true 168 106 184 98 205 98 218 115 218 137 186 164 196 176 195 194 178 195 178 183 188 183 169 164 173 144
Polygon -6459832 true true 207 140 200 163 206 175 207 192 193 189 192 177 198 176 185 150
Polygon -6459832 true true 214 134 203 168 192 148
Polygon -6459832 true true 204 151 203 176 193 148
Polygon -6459832 true true 207 103 221 98 236 101 243 115 243 128 256 142 239 143 233 133 225 115 214 114

wolf-right
false
3
Polygon -6459832 true true 170 127 200 93 231 93 237 103 262 103 261 113 253 119 231 119 215 143 213 160 208 173 189 187 169 190 154 190 126 180 106 171 72 171 73 126 122 126 144 123 159 123
Polygon -6459832 true true 201 99 214 69 215 99
Polygon -6459832 true true 207 98 223 71 220 101
Polygon -6459832 true true 184 172 189 234 203 238 203 246 187 247 180 239 171 180
Polygon -6459832 true true 197 174 204 220 218 224 219 234 201 232 195 225 179 179
Polygon -6459832 true true 78 167 95 187 95 208 79 220 92 234 98 235 100 249 81 246 76 241 61 212 65 195 52 170 45 150 44 128 55 121 69 121 81 135
Polygon -6459832 true true 48 143 58 141
Polygon -6459832 true true 46 136 68 137
Polygon -6459832 true true 45 129 35 142 37 159 53 192 47 210 62 238 80 237
Line -16777216 false 74 237 59 213
Line -16777216 false 59 213 59 212
Line -16777216 false 58 211 67 192
Polygon -6459832 true true 38 138 66 149
Polygon -6459832 true true 46 128 33 120 21 118 11 123 3 138 5 160 13 178 9 192 0 199 20 196 25 179 24 161 25 148 45 140
Polygon -6459832 true true 67 122 96 126 63 144

@#$#@#$#@
NetLogo 3.1.5
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
