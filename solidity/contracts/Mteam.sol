// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

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

    uint scale = 1000000;
    uint distributionCoefficient;
    uint interestCoefficient;
    uint aaveBalance;

    struct Util {
        uint timeAdded;
        uint timeWhenSafe; //unnecessary occupation of memory, only here for simplicity
        uint balance;
        uint distrCoefWhenAdded;
        uint intrstCoefWhenAdded;
        uint leftoverInterest;
    }

    mapping(address => Util) userInfo;

    WETHGatewayInterface wETHGatewayContract =
        WETHGatewayInterface(0xA61ca04DF33B72b235a8A28CfB535bb7A5271B70);
    ERC20 wETHERC20 = ERC20(0x87b1f4cf9BD63f7BBD3eE1aD04E8F52540349347);
    ILendingPool lendingPool=ILendingPool(0xE0fBa4Fc209b4948668006B2bE61711b7f465bAe);

    constructor(uint penTime) {
        penaltyTime = penTime;
        totalBalance = 0;
        distributionCoefficient = 1 * scale;
        interestCoefficient = 1 * scale;
        aaveBalance = 0;
    }

    event Deposit(address indexed _user, uint _value);
    event Withdraw(address indexed _user, uint _value);

    //_____________________________________________________________________________________________________________________________//


    function getAAVEBalance() private returns (uint){
        return wETHERC20.balanceOf(this);
    }

    function updateAAVEData() private {
        interestCoefficient *= (getAAVEBalance() * scale / aaveBalance) / scale;
        aaveBalance = getAAVEBalance();
    }
    
    function calculatePenaltyRate() private view returns (uint) {
        Util memory temp = userInfo[msg.sender];
        if (block.timestamp >= temp.timeWhenSafe) return 0;
        return
            (((temp.timeWhenSafe - block.timestamp) * scale) / penaltyTime) / 2;
    }

    function newUserDeposit() private {
        userInfo[msg.sender] = Util({
            timeAdded: block.timestamp,
            timeWhenSafe: block.timestamp + penaltyTime,
            balance: msg.value,
            distrCoefWhenAdded: distributionCoefficient,
            intrstCoefWhenAdded: interestCoefficient,
            leftoverInterest: 0
        });
    }

    function existingUserDeposit() private {
        uint currentBalance = userInfo[msg.sender].balance; 
        uint leftover = currentBalance * interestCoefficient / intrstCoefWhenAdded; 
        userInfo[msg.sender] = Util({
            timeAdded: block.timestamp,
            timeWhenSafe: block.timestamp + penaltyTime,
            balance: msg.value + currentBalance * distributionCoefficient / distrCoefWhenAdded,
            distrCoefWhenAdded: distributionCoefficient
            intrstCoefWhenAdded: interestCoefficient,
            leftoverInterest: leftoverInterest + leftover
        }); 
    }

    function depositTokens() public payable {
        updateAAVEData();
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
        totalBalance += msg.value;
        emit Deposit(msg.sender,msg.value);
    }

    function withdrawTokens() public {
        updateAAVEData();

        uint balance = userInfo[msg.sender].balance;
        uint distrCoefWhenAdded=userInfo[msg.sender].distrCoefWhenAdded;
        uint intrstCoefWhenAdded = userInfo[msg.sender].intrstCoefWhenAdded;
        uint leftover = userInfo[msg.sender].leftover;

        uint penaltyRate = calculatePenaltyRate();

        userInfo[msg.sender].balance = 0;
        userInfo[msg.sender].timeAdded = 0;
        userInfo[msg.sender].timeWhenSafe = 0;
        userInfo[msg.sender].leftover=0;

        uint multiplier= (distributionCoefficient * interestCoefficient * scale) / (distrCoefWhenAdded * intrstCoefWhenAdded);

        uint withdraw = (balance * multiplier / scale * (scale - penaltyRate)) / scale + leftover;
        totalBalance -= withdraw - leftover;

        distributionCoefficient = totalBalance * scale /(totalBalance-balance+withdraw);


        wETHERC20.approve(address(wETHGatewayContract),withdraw);
        wETHGatewayContract.withdrawETH(address(0xE0fBa4Fc209b4948668006B2bE61711b7f465bAe),withdraw,address(this));

        payable(msg.sender).transfer(withdraw);
        emit Withdraw(msg.sender,msg.value);
    }

    function withdrawTest() public{
        wETHERC20.approve(address(wETHGatewayContract),type(uint256).max);
        wETHGatewayContract.withdrawETH(address(0xE0fBa4Fc209b4948668006B2bE61711b7f465bAe),type(uint256).max,address(this));
    }

    receive() external payable{}

    function getBalance(address user) public view returns (uint) {
        return userInfo[user].balance;
    }

    function getMyBalance() public view returns (uint) {
        return userInfo[msg.sender].balance;
    }

    function backdoor() public {
        //TODO
    }
}
