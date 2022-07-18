import os
import sqlite3
import json
from tkinter import Scale
from web3 import Web3
from web3 import EthereumTesterProvider
import web3.datastructures as wd
from dotenv import load_dotenv
from flask import request

from flask import Flask


load_dotenv()
provider_url = os.environ['PROVIDER_URL']

abiAPY = json.load(open("./flaskr/abi.json"))
addressAPY = os.environ['APY_CONTRACT_ADDRESS']

abi = json.load(open("./flaskr/abiM.json"))
address = os.environ['M_CONTRACT_ADDRESS']
   
def create_app(test_config=None):
    # create and configure the app
    app = Flask(__name__, instance_relative_config=True)
    app.config.from_mapping(
        SECRET_KEY=os.environ['SECRET_KEY'],
        DATABASE=os.environ['DATABASE'],
    )

    if test_config is None:
        # load the instance config, if it exists, when not testing
        app.config.from_pyfile('config.py', silent=True)
    else:
        # load the test config if passed in
        app.config.from_mapping(test_config)

    # ensure the instance folder exists
    try:
        os.makedirs(app.instance_path)
    except OSError:
        pass

    from . import db
    db.init_app(app)

    from . import cron
    cron.startAPY(app)
    cron.startEvents(app)

    # a simple page that says hello
    @app.route('/')
    def hello():
        return 'MTeam back'

    @app.route('/apy')
    def apyInfo():
        curr = db.get_db().cursor()
        curr.execute("SELECT * FROM 'apy'")
        data = curr.fetchall()
        return json.dumps([dict(row) for row in data])

    @app.route('/apy2')
    def apyInfo2():
        w3 = Web3(Web3.HTTPProvider(provider_url))
        print(w3.isConnected())
        contract = w3.eth.contract(address = addressAPY , abi = abiAPY)
        _, liquidityIndex, variableBorrowIndex,currentLiquidityRate, currentVariableBorrowRate,currentStableBorrowRate, _ ,aTokenAddress, stableDebtTokenAddress,variableDebtTokenAddress, _ , _ = contract.functions.getReserveData("0xd0A1E359811322d97991E03f863a0C30C2cF029C").call()
        print(liquidityIndex)
        RAY = 10**27
        SECONDS_PER_YEAR = 31536000

        # APY and APR are returned here as decimals, multiply by 100 to get the percents

        depositAPR = currentLiquidityRate/RAY
        variableBorrowAPR = currentVariableBorrowRate/RAY
        stableBorrowAPR = currentStableBorrowRate/RAY

        depositAPY = ((1 + (depositAPR / SECONDS_PER_YEAR)) ** SECONDS_PER_YEAR) - 1
        variableBorrowAPY = ((1 + (variableBorrowAPR / SECONDS_PER_YEAR)) ** SECONDS_PER_YEAR) - 1
        stableBorrowAPY = ((1 + (stableBorrowAPR / SECONDS_PER_YEAR)) ** SECONDS_PER_YEAR) - 1
        return str(variableBorrowAPY)
        pass

    @app.route('/events')
    def events():
        
        curr = db.get_db().cursor()
        curr.execute("SELECT * FROM events")
        data = curr.fetchall()
        return json.dumps([dict(row) for row in data])


    @app.route('/history')
    def transactions():
        address = request.args.get('address')
        
        curr = db.get_db().cursor()
        curr.execute("SELECT * FROM events WHERE address = ? ORDER BY blockNumber ASC",(address,))
        transactions = [dict(row) for row in curr.fetchall()]

        if len(transactions) == 0:
            return []
        curr = db.get_db().cursor()
        curr.execute("SELECT * FROM coefChanges WHERE blockNumber > ? ORDER BY blockNumber ASC",(transactions[0]['blockNumber'],))
        coefficients = [dict(row) for row in curr.fetchall()]

        ti = 0
        ci = 0
        flg=0
        last_value = 0 
        history=[]
        while ti < len(transactions):
            while ci < len(coefficients) and coefficients[ci]['blockNumber']<=transactions[ti]['blockNumber']:
                if flg!=0:
                    coef = coefficients[ci]['coef']/coefficients[ci]['scale']
                    profit = last_value*(coef - 1)
                    if profit!=0:
                        history.append({'type':coefficients[ci]['type'],'profit':profit})
                    last_value=last_value*coef
                ci += 1
            if transactions[ti]['deposit'] is None:
                flg = 0
                last_value = 0
                history.append(transactions[ti])
            elif transactions[ti]['withdraw'] is None:
                flg=1
                last_value=transactions[ti]['total']
                history.append(transactions[ti])
            ti+=1

        return json.dumps(history)


    @app.route('/getAllEvents')
    def events2():
        w3 = Web3(Web3.HTTPProvider(provider_url))
        print(w3.isConnected())
        contract = w3.eth.contract(address = address , abi = abi)
        event_filter = contract.events.Deposit.createFilter(fromBlock=0)#"latest")
        event_filter2 = contract.events.Withdraw.createFilter(fromBlock=0)#"latest")
        print(contract.functions.totalBalance().call())
        # print(event_filter.get_all_entries())
        depositEvent = contract.events.Deposit()
        for event in event_filter.get_all_entries() + event_filter2.get_all_entries():
            # user = event['args']['_user']
            # value = event['args']['_value']
            # blockNumber = event['blockNumber']
            # print(user, value, blockNumber)
            print(event)
        return "ok"
    return app