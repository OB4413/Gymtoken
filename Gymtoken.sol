// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract    GymToken is ERC20("GymToken", "G"){

    function rewardTokenSubscription(address recipient, uint16 amount) external {
        _mint(recipient, amount);
    }
}