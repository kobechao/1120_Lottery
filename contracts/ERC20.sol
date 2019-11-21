pragma solidity ^0.5.0;

import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";

contract MyToken is ERC20, ERC20Detailed {
    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _amount) ERC20Detailed(_name, _symbol, _decimals) public {
        uint initialSupply = _amount.mul(10**uint256(_decimals));
        _mint(msg.sender, initialSupply);
    }
}