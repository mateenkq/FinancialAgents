import nl4py
import sys
import pandas
import numpy

print("\n1) Starting the NetLogoControllerServer with: nl4py.startServer()\n")


netlogo_home = "C://Program Files//NetLogo 6.0.2//"
nl4py.startServer(netlogo_home)

print('\n2) Starting the model runs... ')

model = "C://Users//Mateen Qureshi//Documents//CSCI378//AFM Initial Migration.nlogo"


n = None

print('\n Creating ' + str(n) + ' NetLogo HeadlessWorkspaces with: workspace = nl4py.newNetLogoHeadlessWorkspace()\n and clearing any old workspaces with nl4py.deleteAllHeadlessWorkspaces()')
print('\n Opening the ' + model + ' model on the NetLogo HeadlessWorkspace with: workspace.openModel("model")')
nl4py.deleteAllHeadlessWorkspaces()
workspace = nl4py.newNetLogoHeadlessWorkspace()
workspace.openModel(model)

print("\n Setting the parameters to random values with workspace.setParamsRandom()")

workspace.setParamsRandom()
# workspace.command('set model-version "sheep-wolves-grass"')
print('\n Send setup command to model using: workspace.command("setup")')

workspace.command("setup")

print('\n Schedule reporters to the model to report the ticks passed, the model\'s two stop conditions and number of sheep and wolves for each tick for 100 ticks,\n using: workspace.scheduleReportersAndRun(reporters,0,1,100,"go")')
print("\t The reporters are: reporters = ['ticks','log-price','returns','volatility'")

reporters = ['ticks','log-price','returns','volatility']
workspace.scheduleReportersAndRun(reporters,0,1,-1,"go")

print("\n2.5) Periodically check the number of ticks passed or if stop conditions are met and... ")
print('\n2.6) Get back all the results from the scheduling process: result = workspace.getScheduledReporterResults():')
print("\tresults = n.getScheduledReporterResults()")

import time

time.sleep(10)

results = workspace.getScheduledReporterResults()
print(workspace.report("log-price"))
print('\t...and put these results into a pandas dataframe: import pandas as pd \n pd.DataFrame(result)')
resultframe = pandas.DataFrame(results)
resultframe.columns = ['ticks','log-price','returns','volatility']
print(resultframe)
print(workspace.report("ticks"))
print('\n3) Shutdown the server to release compute resources using: nl4py.stopServer()')
nl4py.stopServer()
print('\n\n------------------------ Thanks for trying NL4PY -------------------------\n')