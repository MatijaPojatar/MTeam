from sched import scheduler
import time
import atexit
import json

from web3 import Web3
from web3 import EthereumTesterProvider
from apscheduler.schedulers.background import BackgroundScheduler


provider_url = "https://mainnet.infura.io/v3/7ffd9df6885b481d9ab8c0a6a7b215f4"

abi = json.load(open("./flaskr/abi2.json"))
address = '0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9'
token_address = '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2'

def fetchAPY():
    w3 = Web3(Web3.HTTPProvider(provider_url))
    print(w3.isConnected())
    contract = w3.eth.contract(address = address , abi = abi)
    _, liquidityIndex, variableBorrowIndex,currentLiquidityRate, currentVariableBorrowRate,currentStableBorrowRate, _ ,aTokenAddress, stableDebtTokenAddress,variableDebtTokenAddress, _ , _ = contract.functions.getReserveData("0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2").call()
    RAY = 10**27
    SECONDS_PER_YEAR = 31536000

    # APY and APR are returned here as decimals, multiply by 100 to get the percents

    depositAPR = currentLiquidityRate/RAY
    variableBorrowAPR = currentVariableBorrowRate/RAY
    stableBorrowAPR = currentVariableBorrowRate/RAY

    depositAPY = ((1 + (depositAPR / SECONDS_PER_YEAR)) ** SECONDS_PER_YEAR) - 1
    variableBorrowAPY = ((1 + (variableBorrowAPR / SECONDS_PER_YEAR)) ** SECONDS_PER_YEAR) - 1
    stableBorrowAPY = ((1 + (stableBorrowAPR / SECONDS_PER_YEAR)) ** SECONDS_PER_YEAR) - 1
    print(depositAPY, variableBorrowAPY,stableBorrowAPY)


scheduler = BackgroundScheduler()


def start():
    scheduler.add_job(func=fetchAPY, trigger="interval", seconds=10)
    scheduler.start()

# Shut down the scheduler when exiting the app
atexit.register(lambda: scheduler.shutdown())