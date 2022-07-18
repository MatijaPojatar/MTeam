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

contract Indie {
    uint penaltyTime;
    uint public totalBalance;

    uint scale = 10**18;
    uint distributionCoefficient;
    uint interestCoefficient;
    address private owner;
    uint prevBalance;
    uint cntUsers;

    struct Util {
        uint timeAdded;
        uint timeWhenSafe; 
        uint baseValue;
        uint distrCoefWhenAdded;
        uint intrstCoefWhenAdded;
        uint trueBase;
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
        cntUsers = 0;
    }

    event Deposit(address indexed _user, uint _value);
    event Withdraw(address indexed _user, uint _value);

    //_____________________________________________________________________________________________________________________________//

    function depositTokens() public payable {
        updateInterestCoef();
        if(userInfo[msg.sender].timeAdded == 0){
            newUserDeposit();
        }
        else{
            existingUserDeposit();
        }

        wETHGatewayContract.depositETH{value: msg.value}(
            address(0xE0fBa4Fc209b4948668006B2bE61711b7f465bAe),
            address(this),
            0
        );

        emit Deposit(msg.sender,msg.value);
        prevBalance = totalBalance;
        cntUsers++;
    }

    function withdrawTokens() public {
        updateInterestCoef();

        // uint lefteeBaseVal = userInfo[msg.sender].baseValue;
        // uint lefteeTrueBase = userInfo[msg.sender].baseValue;
        // uint lefteeDistrCoefWhenAdded = userInfo[msg.sender].distrCoefWhenAdded;
        // uint lefteeIntrstCoefWhenAdded = userInfo[msg.sender].intrstCoefWhenAdded;
        // uint lefteeTimeWhenAdded = userInfo[msg.sender].timeAdded;
        // uint lefteeTimeWhenSafe = userInfo[msg.sender].timeWhenSafe;
                                                                             
        uint penaltyRate = calculatePenaltyRate();
        uint lefteeTotalBalance = calcUserBalance();
        uint penaltyAmount = penaltyRate * userInfo[msg.sender].trueBase / scale; 
        uint withdraw = lefteeTotalBalance - penaltyAmount;
        uint tempBalance = totalBalance - lefteeTotalBalance;

        wETHERC20.approve(address(wETHGatewayContract),withdraw);
        wETHGatewayContract.withdrawETH(address(0xE0fBa4Fc209b4948668006B2bE61711b7f465bAe),withdraw,address(this));
        payable(msg.sender).transfer(withdraw);

        if(totalBalance == lefteeTotalBalance){
            distributionCoefficient = 1 * scale;
        }
        else{
            distributionCoefficient = distributionCoefficient * (tempBalance + penaltyAmount) / tempBalance;
        }
        
        if(cntUsers == 1){
            uint leftover = getAAVEBalance();
            wETHERC20.approve(address(wETHGatewayContract),leftover);
            wETHGatewayContract.withdrawETH(address(0xE0fBa4Fc209b4948668006B2bE61711b7f465bAe),leftover,address(this));
            payable(owner).transfer(leftover);
        }

        totalBalance = getAAVEBalance();
        prevBalance = totalBalance;
        removeUserData(); 
        cntUsers--;
        emit Withdraw(msg.sender, withdraw);
    }

    function newUserDeposit() private {
        userInfo[msg.sender] = Util({
            timeAdded: block.timestamp,
            timeWhenSafe: block.timestamp,
            baseValue: msg.value,
            distrCoefWhenAdded: distributionCoefficient,
            intrstCoefWhenAdded: interestCoefficient,
            trueBase: msg.value
        });
    }

    function existingUserDeposit() private {
        userInfo[msg.sender] = Util({
            timeAdded: block.timestamp,
            timeWhenSafe: block.timestamp,
            baseValue: msg.value + calcUserBalance(),
            distrCoefWhenAdded: distributionCoefficient,
            intrstCoefWhenAdded: interestCoefficient,
            trueBase: msg.value + userInfo[msg.sender].trueBase
        });    
    }

    function calcUserBalance() private view returns (uint){
        return (userInfo[msg.sender].baseValue * interestCoefficient * distributionCoefficient / (userInfo[msg.sender].intrstCoefWhenAdded) / userInfo[msg.sender].distrCoefWhenAdded);  //mozda probaj naizmenicno deljenje i mnozenje
    }

    function updateInterestCoef() private {
        totalBalance = getAAVEBalance();
        if(prevBalance == 0){
            interestCoefficient = 1 * scale;
        }
        else{
            interestCoefficient = interestCoefficient * totalBalance / prevBalance;
        }
        //transaction
        //prevBalance = totalBalance;
    }

    function updateDistributionCoef() private {

    }


    function getAAVEBalance() private view returns (uint){
        return wETHERC20.balanceOf(address(this));
    }

    function removeUserData() private {
        userInfo[msg.sender] = Util({
            timeAdded: 0,
            timeWhenSafe: 0,
            baseValue: 0,
            distrCoefWhenAdded: 0,
            intrstCoefWhenAdded: 0,
            trueBase: 0
        });
    }

    function calculatePenaltyRate() private view returns (uint) {
        Util memory temp = userInfo[msg.sender];
        if (block.timestamp >= temp.timeWhenSafe) return 0;
        return
            (((temp.timeWhenSafe - block.timestamp) * scale) / penaltyTime) / 2;
    }
}