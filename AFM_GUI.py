import nl4py
import sys
import pandas
import numpy

print("\n1) Starting the NetLogoControllerServer with: nl4py.startServer()\n")


netlogo_home = "C://Program Files//NetLogo 6.0.2//"
nl4py.startServer(netlogo_home)

print('\n2) Starting the model runs... ')

model = "C://Users//Mateen Qureshi//Documents//CSCI378//AFM Initial Migration.nlogo"

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

print('\n Send setup and go commands to the model: n.command("setup") and: n.command("repeat 100 [go]") ')
n.command("setup")
n.command("repeat 100 [go]")
import time

time.sleep(5)
print('\n Get back current state using a NetLogo reporter: n.report("log-price")')
print(n.report("log-price"))

print('\n3.1) Shutdown the NetLogo application using: nl4py.closeModel()')
n.closeModel()

# print('\n3.2) Shutdown the server to release compute resources using: nl4py.stopServer()')
nl4py.stopServer()
