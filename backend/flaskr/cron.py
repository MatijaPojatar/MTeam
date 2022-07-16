from sched import scheduler
import time
import atexit
import json

from web3 import Web3
from web3 import EthereumTesterProvider
from apscheduler.schedulers.background import BackgroundScheduler


provider_url = "https://kovan.infura.io/v3/d535298504ac468eb14672b06e22469a"


token_address = '0xd0A1E359811322d97991E03f863a0C30C2cF029C'
#token_address = '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2'

abiAPY = json.load(open("./flaskr/abi.json"))
addressAPY = '0xE0fBa4Fc209b4948668006B2bE61711b7f465bAe'

abi = json.load(open("./flaskr/abiM.json"))
address = '0x5466acb6ea9081E625EbC34a92807f15eF614a6d'

def fetchAPY(app):
    w3 = Web3(Web3.HTTPProvider(provider_url))
    print(w3.isConnected())
    contract = w3.eth.contract(address = addressAPY , abi = abiAPY)
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

def fetchEvents(app):
    w3 = Web3(Web3.HTTPProvider(provider_url))
    print(w3.isConnected())
    contract = w3.eth.contract(address = address , abi = abi)
    
    with app.app_context():
        from . import db
        curr = db.get_db().cursor()
        
        curr.execute("SELECT max(blockNumber) as t FROM 'events'")
        data = curr.fetchall()
        lastBlock = 0 if data[0][0] is None else data[0][0]+1 
        print('lastBlock', lastBlock)
        event_filter = contract.events.Deposit.createFilter(fromBlock=lastBlock)
        print(contract.functions.totalBalance().call())
        for event in event_filter.get_all_entries():
            user = event['args']['_user']
            value = event['args']['_value']
            blockNumber = event['blockNumber']
            print(user, value, blockNumber)
        
            if event['event']=='Deposit':
                curr.execute(
                ''' INSERT INTO events(address,deposit,blockNumber)
                    VALUES (?,?,?)
                ''', (user,value, blockNumber))
            if event['event']=='Withdraw':
                curr.execute(
                ''' INSERT INTO events(address,withdraw,blockNumber)
                    VALUES (?,?,?)
                ''', (user,value, blockNumber))
            db.get_db().commit()
        
        return True

scheduler = BackgroundScheduler()


def startAPY(app):
    scheduler.add_job(func=fetchAPY, args=[app], trigger="interval", seconds=60)
    if not scheduler.running:
        scheduler.start()

def startEvents(app):
    scheduler.add_job(func=fetchEvents, args=[app], trigger="interval", seconds=10)
    if not scheduler.running:
        scheduler.start()

# Shut down the scheduler when exiting the app
atexit.register(lambda: scheduler.shutdown())