import nl4py
import sys
import pandas
import numpy
import time
from q_learning_trading.StrategyLearner import *
import numpy as np
import datetime as dt
import pandas as pd
import matplotlib.pyplot as plt

from q_learning_trading.util import get_data, create_df_benchmark, create_df_trades
import q_learning_trading.QLearner as ql
from q_learning_trading.indicators import get_momentum, get_sma_indicator, compute_bollinger_value
from q_learning_trading.marketsim import compute_portvals_single_symbol, market_simulator
from q_learning_trading.analysis import get_portfolio_stats

NEUTRAL, POSITIVE, NEGATIVE, HI_POSITIVE, HI_NEGATIVE = 0, 0.05, -0.05, 0.12, -0.12
NEWS_TYPE = NEUTRAL
NEWS_STD = 0.15
NEWS_SENSITIVITY = 0.21
RANDOMIZATION = 6
AGENTS = 20
MAX_PROPENSITY_TO_SENTIMENT_CONTAGION = 0.3

print("\n1) Starting the NetLogoControllerServer with: nl4py.startServer()\n")


netlogo_home = "C://Program Files//NetLogo 6.0.2//"
nl4py.startServer(netlogo_home)

print('\n2) Starting the model runs... ')

model = "C://Users//Mateen Qureshi//Documents//FinancialAgents//AFM_Networks_Final.nlogo"

print('\n Starting the NetLogo Application with: n = nl4py.NetLogoApp()')
n = None
try:
    n = nl4py.NetLogoApp()
except Exception as e:
    print('a')
print('\n Opening the model at ' + model + ' on the NetLogo application with: n.openModel("model")')
n.openModel(model)

print("\n Setting the parameters for the model to random values with: n.setParamsRandom()")
n.setParamsRandom()
n.command("set max-news-sensitivity 0.30")
n.command("set miu 0.01")
n.command("set sigma 0.08")
n.command("set N 15")
n.command("set R 15")

print('\n Send setup and go commands to the model: n.command("setup") and: n.command("repeat 100 [go]") ')
n.command("setup")
start_val = 1000000
symbol = 'YHOO'
commission = 0.00
impact = 0.00
num_shares = 1000
# In-sample or training period
start_date = dt.datetime(2009, 1, 1)
end_date = dt.datetime(2011, 12, 31)

# Get a dataframe of benchmark data. Benchmark is a portfolio starting with
# $100,000, investing in 1000 shares of symbol and holding that position
df_benchmark_trades = create_df_benchmark(symbol, start_date, end_date,
                                          num_shares)

# Train and test a StrategyLearner
stl = StrategyLearner(num_shares=num_shares, impact=impact,
                      commission=commission, verbose=True,
                      num_states=3000, num_actions=3)
stl.add_evidence(symbol=symbol, start_val=start_val,
                 start_date=start_date, end_date=end_date)

start_date = dt.datetime(2012, 1, 1)
num_days = 200
end_date = start_date + dt.timedelta(days=num_days)
next_date = dt.datetime(2012, 1, 2)
dates = pd.date_range(start_date, end_date)
df_prices = get_data([symbol], dates)
curr_price = df_prices.iloc[0, 1]
i = 0
position = stl.CASH
while i < num_days:
    next_date = start_date + dt.timedelta(days=i)
    time.sleep(0.1)
    if i == 0:
        n.command("set log-price {}".format(curr_price))
        n.command("ask turtles [set my-sentiment 1]") #Position is long

    else:
        prev_price = n.report("log-price")
        prev_sentiment = n.report("(sum [my-sentiment] of turtles) / N")
        new_price = prev_price + prev_sentiment
        df_prices.iat[i, 1] = new_price
        if i < 10:
            # new_price = prev_price + prev_sentiment
            # df_prices.at[next_date, symbol] = new_price
            n.command("set returns (sum [my-sentiment] of turtles) / N")
            n.command("set log-price {}".format(new_price))
        else:
            df_features = stl.get_features(df_prices[symbol])
            thresholds = stl.get_thresholds(df_features, stl.num_steps)
            for j in range(1, AGENTS + 1):
                position = n.report("my-sentiment of turtle {}".format(j))
                # print(df_features.iloc[i])
                state = stl.discretize(df_features.iloc[i],
                               position + 1, thresholds)
                print(state)
                action = stl.q_learner.query_set_state(int(state))

                if i == df_features.shape[0] - 1:
                    new_pos = -position
                else:
                    new_pos = stl.get_position(position, action - 1)
                    n.command("my-sentiment of turtle {} = {}".format(j, new_pos))


    n.command("repeat 1 [go]")
    i += 1
import time

time.sleep(5)
print('\n Get back current state using a NetLogo reporter: n.report("log-price")')
print(n.report("log-price"))

print('\n3.1) Shutdown the NetLogo application using: nl4py.closeModel()')
n.closeModel()

# print('\n3.2) Shutdown the server to release compute resources using: nl4py.stopServer()')
nl4py.stopServer()
