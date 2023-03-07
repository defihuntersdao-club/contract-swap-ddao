/* ======================================== DEFI HUNTERS DAO =================================================
                                       https://defihuntersdao.club/                                                                                                             
--------------------------------------------------------------------------------------------------------------
 #######       #######         #####         ####             #####                ###     ####      #######    
##########    ##########       #####      ##########        ######## ####   ####   ####   ######     #########  
###########   ###########     #######    ############      ########  ####   ####   ###    ######     ########## 
####    ####  ####    ####    #######    ####    ####      ###        ###  ###### ####    ######     ###   #### 
####    ####  ####    ####    ### ###   ####      ####     #####      #### ###### ####   ########    ###   #### 
####     ###  ####     ###   #### ####  ####      ####      #######   #### ###### ###    ###  ###    #########  
####     ###  ####     ###   #########  ####      ####       #######  ####### ### ###   ##########   ########   
####    ####  ####    ####  ########### ####      ####          ####   ###### #######   ##########   #####      
####   #####  ####   #####  ###########  ####    ####            ###   ######  #####   ############  ###        
###########   ###########  ####     ###  ###########       #########   #####   #####   ####    ####  ###        
#########     #########    ####     ####   ########        ########     ####   #####   ###     ####  ###      
--------------------------------------------------------------------------------------------------------------  
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/AccessControl.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./admin.sol";

interface IFace
{
    function swapTokensForExactTokens(uint amountOut,uint amountInMax,address[] calldata path,address to,uint deadline) external returns (uint[] memory amounts);
    function swapExactTokensForTokens(uint amountIn,uint amountOutMin,address[] calldata path,address to,uint deadline) external returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] memory path) external view returns (uint[] memory amounts);
    function getAmountsOut(uint amountIn, address[] memory path) external view returns (uint[] memory amounts);
    function allowance(address owner,address spender)external view returns(uint256);
    function balanceOf(address addr)external view returns(uint256);
    function TxsAdd(address addr,uint256 amount,string memory name,uint256 id1,uint256 id2)external returns(uint256);
    function TxsCount(address addr)external returns(uint256);
    function EventAdd(uint256 txcount,address addr,uint256 user_id,uint256 garden,uint256 level,uint256 amount,string memory name)external returns(uint256);
    function Stake(address addr,uint256 amount)external;
    function approve(address spender,uint256 amount)external;
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract swap2 is admin
{

    constructor()
    {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        Admins.push(_msgSender());
        AdminAdd(0x208b02f98d36983982eA9c0cdC6B3208e0f198A3);
        if(_msgSender() != 0x80C01D52e55e5e870C43652891fb44D1810b28A2)
        AdminAdd(0x80C01D52e55e5e870C43652891fb44D1810b28A2);
    }

    function TxsAddrChange(address addr)public onlyAdmin
    {
        require(TxAddr != addr,"This address already set");
        TxAddr = addr;
    }
    function StakeAddrChange(address addr)public onlyAdmin
    {
        require(StakeAddr != addr,"This address already set");
        StakeAddr = addr;
    }


    address public TxAddr = 0xB7CC7b951DAdADacEa3A8E227F25cd2a45c64284;
    address public StakeAddr = 0x877E52d06c0bCbf3Ec1836C0727719644946502A;


    address c_usdc = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;
    address c_usdt = 0xc2132D05D31c914a87C6611C10748AEb04B58e8F;
    address c_dai  = 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063;
    address c_weth = 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619;
    address c_ddao = 0x90F3edc7D5298918F7BB51694134b07356F7d0C7;
    address factory = 0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506;

    struct dev2
    {
        uint256 tx_id;
        uint256 a;
        uint256 deadline;
        uint256 usdc;
        uint256 usdt;
        uint256 dai;
    }
    function Swap(uint256 usdc,uint256 usdt,uint256 dai,uint256 AmountMin,address addr,uint8 stake,uint8 debug)public returns(uint256)
    {
        dev2 memory d;
        d.usdc = usdc;
        d.usdt = usdt;
        d.dai  = dai;
        require(d.usdc > 0 || d.usdt > 0 || d.dai > 0,"Amount of tokens must be more zero.");
        d.tx_id = IFace(TxAddr).TxsAdd(addr,0,"Swap",0,0);
        d.deadline = block.timestamp + 3600;

        address[] memory path3  = new address[](3);
        uint256[] memory v3    = new uint256[](2);

        if(usdc>0)
        {
        d.usdc *= 10**6;
        require(IFace(c_usdc).allowance(addr,address(this))   >= d.usdc,"Check allowance for USDC");
        require(IFace(c_usdc).allowance(address(this),factory) >= d.usdc,"Check allowance from this contract to factory for USDC");

        IFace(c_usdc).transferFrom(addr,address(this),d.usdc);

        path3[0] = c_usdc;
        path3[1] = c_weth;
        path3[2] = c_ddao;

            v3 = IFace(factory).swapExactTokensForTokens(d.usdc,0,path3,address(this),d.deadline);
            IFace(TxAddr).EventAdd(d.tx_id,addr,0,1,0,d.usdc,"SwapUsdcIn");
            IFace(TxAddr).EventAdd(d.tx_id,addr,0,1,0,v3[2],"SwapUsdcOut");
            d.a += v3[2];
        }

        if(usdt > 0)
        {
        d.usdt *= 10**6;

        require(IFace(c_usdt).allowance(addr,address(this))    >= d.usdt,"Check allowance for USDT");
        require(IFace(c_usdt).allowance(address(this),factory) >= d.usdt,"Check allowance from this contract to factory for USDT");

        IFace(c_usdt).transferFrom(addr,address(this),d.usdt);

        path3[0] = c_usdt;
        path3[1] = c_weth;
        path3[2] = c_ddao;
            v3 = IFace(factory).swapExactTokensForTokens(d.usdt,0,path3,address(this),d.deadline);
            IFace(TxAddr).EventAdd(d.tx_id,addr,0,2,0,d.usdt,"SwapUsdtIn");
            IFace(TxAddr).EventAdd(d.tx_id,addr,0,2,0,v3[2],"SwapUsdtOut");
            d.a += v3[2];
        }

        if(dai > 0)
        {
        d.dai *= 10**18;

        require(IFace(c_dai).allowance(addr,address(this)) >= d.dai,"Check allowance for DAI");
        require(IFace(c_dai).allowance(address(this),factory) >= d.dai,"Check allowance from this contract to factory for DAI ");

        IFace(c_dai).transferFrom(addr,address(this),d.dai);

        path3[0] = c_dai;
        path3[1] = c_weth;
        path3[2] = c_ddao;
            v3 = IFace(factory).swapExactTokensForTokens(d.dai,0,path3,address(this),d.deadline);
            IFace(TxAddr).EventAdd(d.tx_id,addr,0,3,0,d.dai,"SwapDaiIn");
            IFace(TxAddr).EventAdd(d.tx_id,addr,0,3,0,v3[2],"SwapDaiOut");
            d.a += v3[2];
        }
        require(d.a >= AmountMin,"Requested DDAO must be more then AmountMin.");

        if(stake==1)
        {
            IFace(c_ddao).approve(StakeAddr,d.a);

    	    IFace(StakeAddr).Stake(addr,d.a);
            IFace(TxAddr).EventAdd(d.tx_id,addr,0,4,0,d.a,"Stake");
        }
        else
        {
    	    IFace(c_ddao).transfer(addr, d.a);
            IFace(TxAddr).EventAdd(d.tx_id,addr,0,5,0,d.a,"Transfer");
        }

        return d.a;
    }
    function AllowanceUsdc(address addr)public view returns(uint256 out)
    {
        if(addr == address(0))addr = address(this);
        out = IFace(c_usdc).allowance(address(this),addr);
    }
    function AllowanceUsdt(address addr)public view returns(uint256 out)
    {
        if(addr == address(0))addr = address(this);
        out = IFace(c_usdt).allowance(address(this),addr);
    }
    function AllowanceDai(address addr)public view returns(uint256 out)
    {
        if(addr == address(0))addr = address(this);
        out = IFace(c_dai).allowance(address(this),addr);
    }
    function ApproveMe()public onlyAdmin
    {
        int256 i = -1;
        uint256 a = uint256(i);
        IFace(c_usdc).approve(factory,a);
        IFace(c_usdt).approve(factory,a);
        IFace(c_dai).approve(factory,a);
    }
    function ApproveUsdc(uint256 amount)public onlyAdmin
    {
        IFace(c_usdc).approve(factory,amount);
    }
    function ApproveUsdt(uint256 amount)public onlyAdmin
    {
        IFace(c_usdt).approve(factory,amount);
    }

    function ApproveDai(uint256 amount)public onlyAdmin
    {
        IFace(c_dai).approve(factory,amount);
    }
    function OnlyStake(address addr,uint256 amount)public returns(uint256)
    {
	if(addr == address(0))addr = _msgSender();
	require(IFace(c_ddao).allowance(addr,address(this)) >= amount,"Check allowance for DDAO");
        IFace(c_ddao).transferFrom(addr,address(this),amount);
	IFace(c_ddao).approve(StakeAddr,amount);
        IFace(StakeAddr).Stake(addr,amount);
    }

}