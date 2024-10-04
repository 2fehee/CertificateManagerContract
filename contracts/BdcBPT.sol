pragma solidity ^0.5.0;

import "../node_modules/@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/ERC20Detailed.sol";
import "../node_modules/@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/ERC20Mintable.sol";
test
test
test
test
contract BdcBPT is
   ERC20Detailed, 
   ERC20Mintable
{
    
    function initialize(
        string memory name, string memory symbol, uint8 decimals, uint256 initialSupply, address initialHolder
    ) public initializer  
    {  
        ERC20Detailed.initialize(name, symbol, decimals);

        _mint(initialHolder, initialSupply);
        
        ERC20Mintable.initialize(address(this));
    }
    
}