// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.12;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Token is ERC20Votes, Ownable {
    constructor(
        string memory name, 
        string memory symbol
    ) ERC20(name, symbol) ERC20Permit(name) {}

    function mint(address to, uint256 amount) external onlyOwner {
        ERC20Votes._mint(to, amount);
    }

    function burn(address to, uint256 amount) external onlyOwner {
        ERC20Votes._burn(to, amount);
    }
}