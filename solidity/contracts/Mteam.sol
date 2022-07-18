// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "hardhat/console.sol";


interface WETHGatewayInterface {
    function depositETH(
        address lendingPool,
        address onBehalfOf,
        uint16 referralCode
    ) external payable;
    function withdrawETH(
    address lendingPool,
    uint256 amount,
    address onBehalfOf
  ) external;
}

interface ILendingPool {
    function deposit(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external;
}

contract Mteam {
    uint penaltyTime;
    uint public totalBalance;

    uint scale = 10**18;
    uint distributionCoefficient;
    uint interestCoefficient;
    address private owner;
    uint prevBalance;
    uint userCount;

    struct Util {
        uint timeAdded;
        uint timeWhenSafe; //unnecessary occupation of memory, only here for simplicity
        uint balance;
        uint distrCoefWhenAdded;
        uint intrstCoefWhenAdded;
        uint trueBalance;
    }

    mapping(address => Util) userInfo;

    WETHGatewayInterface wETHGatewayContract =
        WETHGatewayInterface(0xA61ca04DF33B72b235a8A28CfB535bb7A5271B70);
    ERC20 wETHERC20 = ERC20(0x87b1f4cf9BD63f7BBD3eE1aD04E8F52540349347);
    ILendingPool lendingPool=ILendingPool(0xE0fBa4Fc209b4948668006B2bE61711b7f465bAe);

    constructor(uint penTime) {
        owner = msg.sender;
        penaltyTime = penTime;
        totalBalance = 0;
        distributionCoefficient = 1 * scale;
        interestCoefficient = 1 * scale;
        prevBalance = 0;
        userCount=0;
    }

    event Deposit(address indexed _user, uint _value);
    event Withdraw(address indexed _user, uint _value);
    event CalcDistrCoefEvent(address indexed _user, uint _factor);
    event CalcIntrstCoefEvent(address indexed _user, uint _factor);

    //_____________________________________________________________________________________________________________________________//


    function getAAVEBalance() private view returns (uint){
        return wETHERC20.balanceOf(address(this));
    }

    function calculateInterestCoefficient(uint prevBalanceTemp,uint totalBalanceTemp) internal view returns(uint){
        if(prevBalanceTemp==0){
            return 1 * scale;
        }else{
            return  interestCoefficient * totalBalanceTemp  / prevBalanceTemp ;
        }
    }

    function updateAAVEData() private {
        console.log("===========UPDATE===========");
        console.log("Prev balance: %i",prevBalance);
        console.log("Total balance: %i",totalBalance);
        prevBalance=totalBalance;
        totalBalance=getAAVEBalance();
        console.log("+++++++++++++++++");
        console.log("Prev balance: %i",prevBalance);
        console.log("Total balance: %i",totalBalance);
        interestCoefficient=calculateInterestCoefficient(prevBalance,totalBalance);
        if(prevBalance == 0){
            emit CalcIntrstCoefEvent(msg.sender,1);
        }
        else{
            emit CalcIntrstCoefEvent(msg.sender,totalBalance/prevBalance);
        }
        console.log("Interest coef: %i",interestCoefficient);
        console.log("===========END_UPDATE===========");
    }
    
    function calculatePenaltyRate() private view returns (uint) {
        Util memory temp = userInfo[msg.sender];
        if (block.timestamp >= temp.timeWhenSafe) return 0;
        return
            (((temp.timeWhenSafe - block.timestamp) * scale) / penaltyTime) / 2;
    }

    function newUserDeposit() private {
        updateAAVEData();
        userInfo[msg.sender] = Util({
            timeAdded: block.timestamp,
            timeWhenSafe: block.timestamp + penaltyTime,
            balance: msg.value,
            distrCoefWhenAdded: distributionCoefficient,
            intrstCoefWhenAdded: interestCoefficient,
            trueBalance: msg.value
        });
    }

    function existingUserDeposit() private {
        updateAAVEData();
        uint currentBalance = userInfo[msg.sender].balance; 
        uint leftover = currentBalance * interestCoefficient * distributionCoefficient / (userInfo[msg.sender].intrstCoefWhenAdded * userInfo[msg.sender].distrCoefWhenAdded); 
        userInfo[msg.sender] = Util({
            timeAdded: block.timestamp,
            timeWhenSafe: block.timestamp + penaltyTime,
            balance: msg.value + leftover,
            distrCoefWhenAdded: distributionCoefficient,
            intrstCoefWhenAdded: interestCoefficient,
            trueBalance: userInfo[msg.sender].trueBalance + msg.value
        }); 
    }

    function depositTokens() public payable {
        userCount=userCount+1;
        if (userInfo[msg.sender].timeAdded == 0) {
            newUserDeposit();
        } else {
            existingUserDeposit();
        }
        wETHGatewayContract.depositETH{value: msg.value}(
            address(0xE0fBa4Fc209b4948668006B2bE61711b7f465bAe),
            address(this),
            0
        );
        totalBalance = getAAVEBalance();
        emit Deposit(msg.sender,msg.value);
    }

    function withdrawTokens() public {
        updateAAVEData();
        userCount=userCount-1;

        uint balance = userInfo[msg.sender].balance;
        uint distrCoefWhenAdded=userInfo[msg.sender].distrCoefWhenAdded;
        uint intrstCoefWhenAdded = userInfo[msg.sender].intrstCoefWhenAdded;
        uint trueBalance = userInfo[msg.sender].trueBalance;

        uint penaltyRate = calculatePenaltyRate();
        console.log("Penalty rate: %i",penaltyRate);

        userInfo[msg.sender].balance = 0;
        userInfo[msg.sender].timeAdded = 0;
        userInfo[msg.sender].timeWhenSafe = 0;

        console.log("Distribution coef: %i",distributionCoefficient);
        console.log("Interest coef: %i",interestCoefficient);

        uint balanceOfLeftee = (balance * distributionCoefficient * interestCoefficient / (distrCoefWhenAdded * intrstCoefWhenAdded));
        console.log("Balance of Leftee: %i",balanceOfLeftee);

        //getAAVEBalance();
        console.log("Total balance: %i",totalBalance);
        
        uint penalty = (penaltyRate * trueBalance) / scale;

        uint tempBalance = totalBalance - balanceOfLeftee;

        uint withdraw = balanceOfLeftee - penalty;
        console.log("Withdraw: %i",withdraw);

        wETHERC20.approve(address(wETHGatewayContract),withdraw);
        wETHGatewayContract.withdrawETH(address(0xE0fBa4Fc209b4948668006B2bE61711b7f465bAe),withdraw,address(this));

        payable(msg.sender).transfer(withdraw);

        if(userCount==0){
            distributionCoefficient = 1 * scale;
            interestCoefficient = 1 * scale;
            emit CalcIntrstCoefEvent(msg.sender, 1);
            emit CalcDistrCoefEvent(msg.sender, 1);
        }else{
            console.log("Penalty: %i",penalty);
            console.log("Temp balance: %i",tempBalance);
            console.log("Dist coef before: %i",distributionCoefficient);
            distributionCoefficient = distributionCoefficient * (totalBalance - withdraw)  /  tempBalance; 
            emit CalcDistrCoefEvent(msg.sender, (totalBalance - withdraw) / tempBalance);
            console.log("Dist coef after: %i",distributionCoefficient);
        }

        console.log("Distribution coef: %i",distributionCoefficient);
        console.log("Interest coef: %i",interestCoefficient);


        emit Withdraw(msg.sender,withdraw);
    
        totalBalance=getAAVEBalance();
        console.log("Total balance: %i",totalBalance);
    }

    receive() external payable{}

    function getBalance(address user) public view returns (uint) {
        return userInfo[user].balance;
    }

    function getMyBalance() public view returns (uint) {
        uint balance = userInfo[msg.sender].balance;
        uint distrCoefWhenAdded=userInfo[msg.sender].distrCoefWhenAdded;
        uint intrstCoefWhenAdded = userInfo[msg.sender].intrstCoefWhenAdded;
        uint trueBalance = userInfo[msg.sender].trueBalance;

        uint tempPrevBalance=totalBalance;
        uint tempTotalBalance=getAAVEBalance();

        uint penaltyRate = calculatePenaltyRate();

        uint interestCoefficientTemp=calculateInterestCoefficient(tempPrevBalance,tempTotalBalance);

        uint balanceOfLeftee = (balance * distributionCoefficient * interestCoefficientTemp / (distrCoefWhenAdded * intrstCoefWhenAdded));

        uint penalty = (penaltyRate * trueBalance) / scale;

        uint withdraw = balanceOfLeftee - penalty;

        console.log("Withdraw BROOOOOOOOOOOOOOOOOOOOOOOOO: %i",withdraw);

        return withdraw;
    }

    function getPoolBalance() public view returns (uint) {
        return getAAVEBalance();
    }

    function backdoor() public {
        //TODO
    }
}
