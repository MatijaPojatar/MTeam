import os
import sqlite3
import json
from web3 import Web3
from web3 import EthereumTesterProvider
import web3.datastructures as wd

from flask import Flask

provider_url = "https://kovan.infura.io/v3/d535298504ac468eb14672b06e22469a"

abiAPY = json.load(open("./flaskr/abi.json"))
addressAPY = '0xE0fBa4Fc209b4948668006B2bE61711b7f465bAe'

abi = json.load(open("./flaskr/abiM.json"))
address = '0x5466acb6ea9081E625EbC34a92807f15eF614a6d'
   
def create_app(test_config=None):
    # create and configure the app
    app = Flask(__name__, instance_relative_config=True)
    app.config.from_mapping(
        SECRET_KEY='dev',
        DATABASE='mteam.db',
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
        w3 = Web3(Web3.HTTPProvider(provider_url))
        print(w3.isConnected())
        contract = w3.eth.contract(address = address , abi = abi)
        event_filter = contract.events.Deposit.createFilter(fromBlock=0)#"latest")
        print(contract.functions.totalBalance().call())
        # print(event_filter.get_all_entries())
        depositEvent = contract.events.Deposit()
        for event in event_filter.get_all_entries():
            user = event['args']['_user']
            value = event['args']['_value']
            blockNumber = event['blockNumber']
            print(user, value, blockNumber)
        return "ok"
        pass

    return app