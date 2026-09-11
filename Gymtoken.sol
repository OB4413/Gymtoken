// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract    GymToken is ERC20("GymToken", "G"),Ownable(msg.sender){
    struct prodact{
        string name;
        string description;
        uint256 stok;
        uint256 price;
        string[]  prodactImage;
    }
    struct prodactById{
        uint256 id;
        prodact prodacts;
    }
    mapping(address => prodactById[]) internal  marketplus;

    event   SubscriptionPaid(address indexed client, address indexed GymOwner, uint256 amount);

    function rewardTokenSubscription(address recipient, uint256 amount) external onlyOwner{
        _mint(recipient, amount);
    }

    function paySubscription(address GymOwner, uint256 amount) external {
        address clinet = msg.sender;

        transferFrom(clinet, GymOwner, amount);
        emit SubscriptionPaid(clinet, GymOwner, amount);
    }

    function    addProdact(uint256 _ProdactId, string memory _name, string memory _description, uint256 _stok, uint256 _price, string[] memory _prodactImage) external {
        prodact memory newProdact = prodact(_name, _description, _stok, _price, _prodactImage);
        prodactById memory p = prodactById(_ProdactId, newProdact);
        marketplus[msg.sender].push(p);
    }

    function findTheProdactById(uint256 _PodactId) internal view returns (uint256) {
        for (uint256 i = 0; i < marketplus[msg.sender].length; i++) {
            if (marketplus[msg.sender][i].id == _PodactId) return i;
        }
        return 0;
    }

    function    editProdact(uint256 _ProdactId, string memory _name, string memory _description, uint256 _stok, uint256 _price, string[] memory _prodactImage) external {
        uint256 indx = findTheProdactById(_ProdactId);
        marketplus[msg.sender][indx].prodact.name = _name;
    }

    function    removeProdact(uint256 _ProdactId) external {
        prodactById memory newprodactById = findTheProdactById(_ProdactId);
        delete marketplus[msg.sender][_ProdactId];
    }
}