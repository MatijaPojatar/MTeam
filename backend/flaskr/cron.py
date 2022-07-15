from sched import scheduler
import time
import atexit
import json

from web3 import Web3
from web3 import EthereumTesterProvider
from apscheduler.schedulers.background import BackgroundScheduler


provider_url = "https://kovan.infura.io/v3/d535298504ac468eb14672b06e22469a"

abi = json.load(open("./flaskr/abi.json"))
address = '0xE0fBa4Fc209b4948668006B2bE61711b7f465bAe'
#address = '0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9'
token_address = '0xd0A1E359811322d97991E03f863a0C30C2cF029C'
#token_address = '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2'

def fetchAPY(app):
    w3 = Web3(Web3.HTTPProvider(provider_url))
    print(w3.isConnected())
    contract = w3.eth.contract(address = address , abi = abi)
    _, liquidityIndex, variableBorrowIndex,currentLiquidityRate, currentVariableBorrowRate,currentStableBorrowRate, lastUpdateTimestamp ,aTokenAddress, stableDebtTokenAddress,variableDebtTokenAddress, _ , _ = contract.functions.getReserveData("0xd0A1E359811322d97991E03f863a0C30C2cF029C").call()
    RAY = 10**27
    SECONDS_PER_YEAR = 31536000

    # APY and APR are returned here as decimals, multiply by 100 to get the percents

    depositAPR = currentLiquidityRate/RAY
    variableBorrowAPR = currentVariableBorrowRate/RAY
    stableBorrowAPR = currentStableBorrowRate/RAY

    depositAPY = ((1 + (depositAPR / SECONDS_PER_YEAR)) ** SECONDS_PER_YEAR) - 1
    variableBorrowAPY = ((1 + (variableBorrowAPR / SECONDS_PER_YEAR)) ** SECONDS_PER_YEAR) - 1
    stableBorrowAPY = ((1 + (stableBorrowAPR / SECONDS_PER_YEAR)) ** SECONDS_PER_YEAR) - 1
    print(depositAPY, variableBorrowAPY,stableBorrowAPY)

    
    # from . import db
    # curr = db.get_db().cursor()
    # curr.execute("SELECT * FROM 'apy'")
    # data = curr.fetchall()
    # print([dict(row) for row in data])

    with app.app_context():
        from . import db
        curr = db.get_db().cursor()
        

        curr.execute("SELECT max(timestamp) as t FROM 'apy'")
        data = curr.fetchall()
        print(data[0][0])
        if data[0][0] is None or data[0][0]<lastUpdateTimestamp :
            curr.execute(
            ''' INSERT INTO apy(timestamp,depositAPY, variableBorrowAPY,stableBorrowAPY)
                VALUES (?,?,?,?)
            ''', (lastUpdateTimestamp,depositAPY, variableBorrowAPY,stableBorrowAPY))
            db.get_db().commit()
        return True


scheduler = BackgroundScheduler()


def start(app):
    scheduler.add_job(func=fetchAPY, args=[app], trigger="interval", seconds=10)
    scheduler.start()

# Shut down the scheduler when exiting the app
atexit.register(lambda: scheduler.shutdown())