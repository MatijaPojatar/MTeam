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

    uint scale = 10000;
    uint basePenalty = 5000;
    uint coefScale = 1000000;
    uint coef;

    struct Util {
        uint timeAdded;
        uint timeWhenSafe; //unnecessary occupation of memory, only here for simplicity
        uint balance;
        uint coefWhenAdded;
    }

    mapping(address => Util) userInfo;

    WETHGatewayInterface wETHGatewayContract =
        WETHGatewayInterface(0xA61ca04DF33B72b235a8A28CfB535bb7A5271B70);
    ERC20 wETHERC20 = ERC20(0x87b1f4cf9BD63f7BBD3eE1aD04E8F52540349347);
    ILendingPool lendingPool=ILendingPool(0xE0fBa4Fc209b4948668006B2bE61711b7f465bAe);

    /*modifier onlyOwner{
        require(msg.sender==admin, "YOu are not admin");
        _;
    }*/

    constructor(uint penTime) {
        penaltyTime = penTime;
        totalBalance = 0;
        coef=1000000;
    }

    //__________________________________________________________________________//


    function calculatePenaltyRate() private view returns (uint) {
        //returns percentage of tokens that user will be penalised by
        Util memory temp = userInfo[msg.sender];
        if (block.timestamp >= temp.timeWhenSafe) return 0;
        return
            (((temp.timeWhenSafe - block.timestamp) * scale) / penaltyTime) / 2;
    }

    function newUserDeposit() private {
        //maybe should be payable
        userInfo[msg.sender] = Util({
            timeAdded: block.timestamp,
            timeWhenSafe: block.timestamp + penaltyTime,
            balance: msg.value,
            coefWhenAdded: coef
        });
        //call aave
    }

    function existingUserDeposit() private {
        uint currentBalance = userInfo[msg.sender].balance; //maybe should be payable
        userInfo[msg.sender] = Util({
            timeAdded: block.timestamp,
            timeWhenSafe: block.timestamp + penaltyTime,
            balance: msg.value + currentBalance,
            coefWhenAdded: coef
        }); //msg.value maybe not accessible cause of depth of call stack
        //call aave
    }

    function depositTokens() public payable {
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
    }

    function withdrawTokens() public {
        uint balance = userInfo[msg.sender].balance;
        uint coefWhenAdded=userInfo[msg.sender].coefWhenAdded;
        userInfo[msg.sender].balance = 0;
        userInfo[msg.sender].timeAdded=0;
        userInfo[msg.sender].timeWhenSafe=0;
        uint penaltyRate = calculatePenaltyRate();

        uint multiplier= coef * coefScale / coefWhenAdded;

        uint oldBalance=totalBalance;
        uint withdraw = (balance * multiplier / coefScale * (scale - penaltyRate)) / scale;
        totalBalance -= withdraw;
        coef=oldBalance * coefScale /totalBalance;

        wETHERC20.approve(address(wETHGatewayContract),withdraw);
        wETHGatewayContract.withdrawETH(address(0xE0fBa4Fc209b4948668006B2bE61711b7f465bAe),withdraw,address(this));

        payable(msg.sender).transfer(withdraw);
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

    function screwOverUser() public {
        //
    }
}
