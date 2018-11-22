"""Market simulator"""

import pandas as pd
import numpy as np
import datetime as dt
import os
from analysis import get_portfolio_value, get_portfolio_stats, plot_normalized_data
import sys
# Append the path of the directory one level above the current directory to import util
sys.path.append('../')
from util import *


def compute_portvals(orders_file = "./orders/orders.csv", start_val = 1000000, commission=9.95, impact=0.005):
    """
    Parameters:
    orders_file: The name of a file from which to read orders; may be a string, or a file object
    start_val: The starting value of the portfolio (initial cash available)
    commission: The fixed amount in dollars charged for each transaction (both entry and exit)
    impact: The amount the price moves against the trader compared to the historical data at each transaction
    
    Returns:
    portvals: A dataframe with one column containing the value of the portfolio for each trading day
    """

    # Read in the orders_file and sort it by date
    orders_df = pd.read_csv(orders_file, index_col='Date', parse_dates=True, na_values=['nan'])
    orders_df.sort_index(ascending=True, inplace=True)
    
    # Get the start and end dates and symbols
    start_date = orders_df.index.min()
    end_date = orders_df.index.max()
    symbols = orders_df.Symbol.unique().tolist()

    # Create a dataframe with adjusted close prices for the symbols and for cash
    df_prices = get_data(symbols, pd.date_range(start_date, end_date), addSPY=True)
    del df_prices["SPY"]
    df_prices["cash"] = 1.0

    # Fill NAN values if any
    df_prices.fillna(method="ffill", inplace=True)
    df_prices.fillna(method="bfill", inplace=True)
    df_prices.fillna(1.0, inplace=True)

    # Create a dataframe that represents changes in the number of shares by day for each asset. 
    # It has the same structure as df_prices, and is initially filled with zeros
    df_trades = pd.DataFrame(np.zeros((df_prices.shape)), df_prices.index, df_prices.columns)
    for index, row in orders_df.iterrows():
        # Total value of shares purchased or sold
        traded_share_value = df_prices.loc[index, row["Symbol"]] * row["Shares"]
        # Transaction cost 
        transaction_cost = commission + impact * traded_share_value

        # Update the number of shares and cash based on the type of transaction done
        # Note: The same asset may be traded more than once on a particular day
        if row["Order"] == "BUY":
            df_trades.loc[index, row["Symbol"]] = df_trades.loc[index, row["Symbol"]] + row["Shares"]
            df_trades.loc[index, "cash"] = df_trades.loc[index, "cash"] + traded_share_value * (-1.0) - transaction_cost
        else:
            df_trades.loc[index, row["Symbol"]] = df_trades.loc[index, row["Symbol"]] -row["Shares"]
            df_trades.loc[index, "cash"] = df_trades.loc[index, "cash"] + traded_share_value - transaction_cost

    # Create a dataframe that represents on each particular day how much of each asset in the portfolio
    # It has the same structure as df_prices, and is initially filled with zeros
    df_holdings = pd.DataFrame(np.zeros((df_prices.shape)), df_prices.index, df_prices.columns)
    for row_count in range(len(df_holdings)):
        # In the first row, the shares are the same as in df_trades, but start_val must be added to cash
        if row_count == 0:
            df_holdings.iloc[0, :-1] = df_trades.iloc[0, :-1].copy()
            df_holdings.iloc[0, -1] = df_trades.iloc[0, -1] + start_val
        # The rest of the rows show cumulative values
        else:
            df_holdings.iloc[row_count] = df_holdings.iloc[row_count-1] + df_trades.iloc[row_count]
        row_count += 1

    # Create a dataframe that represents the monetary value of each asset in the portfolio
    df_value = df_prices * df_holdings
    
    # Create portvals dataframe
    portvals = pd.DataFrame(df_value.sum(axis=1), df_value.index, ["port_val"])
    return portvals


def market_simulator(orders_file, start_val=1000000, daily_rf=0.0, samples_per_year=252.0, 
    save_fig=False, fig_name="plot.png"):
    """
    This function takes in an orders file and execute trades based on the file

    Parameters:
    orders_file: The file whose orders will be execute
    start_val: The starting cash in dollars
    daily_rf: Daily risk-free rate, assuming it does not change
    samples_per_year: Sampling frequency per year

    Returns:
    Print out final portfolio value of the portfolio, as well as Sharpe ratio, 
    cumulative return, average daily return and standard deviation of the portfolio and $SPX.
    Plot a chart of the portfolio and $SPX performances

    """
    
    # Process orders
    portvals = compute_portvals(orders_file=orders_file, start_val=start_val)
    if not isinstance(portvals, pd.DataFrame):
        print ("warning, code did not return a DataFrame")
    
    # Get portfolio stats
    cum_ret, avg_daily_ret, std_daily_ret, sharpe_ratio = get_portfolio_stats(portvals,
     daily_rf=daily_rf, samples_per_year=samples_per_year)
    
    # Get the stats for $SPX for the same date range for comparison
    start_date = portvals.index.min()
    end_date = portvals.index.max()
    SPX_prices = get_data(["$SPX"], pd.date_range(start_date, end_date), addSPY=False).dropna()
    cum_ret_SPX, avg_daily_ret_SPX, std_daily_ret_SPX, sharpe_ratio_SPX = \
    get_portfolio_stats(SPX_prices, daily_rf=daily_rf, samples_per_year=samples_per_year)

    # Compare portfolio against $SPX
    print ("Date Range: {} to {}".format(start_date, end_date))
    print ()
    print ("Sharpe Ratio of Fund: {}".format(sharpe_ratio))
    print ("Sharpe Ratio of $SPX : {}".format(sharpe_ratio_SPX))
    print ()
    print ("Cumulative Return of Fund: {}".format(cum_ret))
    print ("Cumulative Return of $SPX : {}".format(cum_ret_SPX))
    print ()
    print ("Standard Deviation of Fund: {}".format(std_daily_ret))
    print ("Standard Deviation of $SPX : {}".format(std_daily_ret_SPX))
    print ()
    print ("Average Daily Return of Fund: {}".format(avg_daily_ret))
    print ("Average Daily Return of $SPX : {}".format(avg_daily_ret_SPX))
    print ()
    print ("Final Portfolio Value: {}".format(portvals.iloc[-1, -1]))

    # Plot the data
    plot_normalized_data(SPX_prices.join(portvals), "Portfolio vs. SPX", "Date", "Normalized prices",
        save_fig=save_fig, fig_name=fig_name)


if __name__ == "__main__":
    market_simulator(orders_file="./orders/orders.csv", save_fig=True, fig_name="orders.png")
    market_simulator(orders_file="../02b_event_analyzer/df_trades.csv", 
        save_fig=True, fig_name="df_trades.png")
    market_simulator(orders_file="../02b_event_analyzer/df_trades_bollinger.csv", 
        save_fig=True, fig_name="df_trades_bollinger.png")