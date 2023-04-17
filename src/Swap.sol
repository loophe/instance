// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;   


// import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "./IV3SwapRouter.sol";
import "./IERC20.sol";

interface IWETH is IERC20 {
    function deposit() external payable;
    function withdraw(uint) external;
}

contract Swap {

    address public constant _swapRouter = 0xE592427A0AEce92De3Edee1F18E0157C05861564;//Main
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; //Main
    IWETH public constant weth = IWETH(WETH);//Main
 
    IV3SwapRouter public UniswapRouterV3 = IV3SwapRouter(_swapRouter);

    function uniswapRouterSwap 
    (
        address _collateral, 
        address _reserve, 
        uint256 _amountIn, 
        uint256 _amountMin, 
        uint24 _poolFee
    ) 
        internal returns (bool success)
    {
        success = false;
        if (_collateral == address(WETH) || _reserve == address(WETH)){
            uint256 amountOut =  
                swapExactInputSingle
                (
                    _collateral, 
                    _reserve, 
                    _amountIn, 
                    _amountMin, 
                    _poolFee
                );
            if (amountOut > _amountMin)return success = true;
        }else{
            uint256 amountOut =
                swapExactInput
                (
                    _collateral, 
                    _reserve,
                    _amountIn,
                    _amountMin,
                    _poolFee
                );
            if (amountOut > _amountMin)return success = true;
        }
    }

    function swapExactInputSingle
    (
        address _collateral, 
        address _reserve, 
        uint256 _amountIn, 
        uint256 _amountMin, 
        uint24 _poolFee
    )   
        internal returns (uint256 amountOut) 
    {
     
        // swapRouter = IV3SwapRouter(_swapRouter);

        // Approve the router to spend USDC.
        // TransferHelper.safeApprove(_collateral, _swapRouter, _amountIn);

        // Naively set amountOutMinimum to 0. In production, use an oracle or other data source to choose a safer value for amountOutMinimum.
        // We also set the sqrtPriceLimitx96 to be 0 to ensure we swap our exact input amount.
        IV3SwapRouter.ExactInputSingleParams memory params =
            IV3SwapRouter.ExactInputSingleParams({
                tokenIn: _collateral,
                tokenOut: _reserve,
                fee: _poolFee,
                recipient: address(this),
                deadline: block.timestamp + 200,
                amountIn: _amountIn,
                amountOutMinimum: _amountMin,
                sqrtPriceLimitX96: 0
            });

        // The call to `exactInputSingle` executes the swap.
        amountOut = UniswapRouterV3.exactInputSingle(params);
        // this.balanceOfThis(_reserve);
    }

    function swapExactInput
    (
        address _collateral, 
        address _reserve, 
        uint256 _amountIn, 
        uint256 _amountMin, 
        uint24 _poolFee
    )   internal 
        returns (uint256 amountOut) 
    {
        // swapRouter = IV3SwapRouter(_swapRouter);
        
        // TransferHelper.safeApprove(_collateral, _swapRouter, _amountIn);

        bytes memory path = abi.encodePacked(_collateral, _poolFee, address(WETH), _poolFee, _reserve);
        
        IV3SwapRouter.ExactInputParams memory params =
            IV3SwapRouter.ExactInputParams({
                path: path,
                recipient: address(this),  
                amountIn: _amountIn,
                amountOutMinimum: _amountMin
            });

        amountOut = UniswapRouterV3.exactInput(params);

    }

}