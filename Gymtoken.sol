// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GymToken is ERC20("GymToken", "G"), Ownable(msg.sender) {
    
    struct prodact {
        string name;
        string description;
        uint256 stok;
        uint256 price;
        string[] prodactImage;
    }
    
    struct prodactById {
        uint256 id;
        prodact prodacts;
    }
    
    mapping(address => prodactById[]) internal marketplus;

    event SubscriptionPaid(address indexed client, address indexed GymOwner, uint256 amount);

    function rewardTokenSubscription(address recipient, uint256 amount) external onlyOwner {
        _mint(recipient, amount);
    }

    function paySubscription(address GymOwner, uint256 amount) external {
        address clinet = msg.sender;
        transferFrom(clinet, GymOwner, amount);
        emit SubscriptionPaid(clinet, GymOwner, amount);
    }

    function addProdact(uint256 _ProdactId, string memory _name, string memory _description, uint256 _stok, uint256 _price, string[] memory _prodactImage) external {
        prodact memory newProdact = prodact(_name, _description, _stok, _price, _prodactImage);
        prodactById memory p = prodactById(_ProdactId, newProdact);
        marketplus[msg.sender].push(p);
    }

    function findTheProdactIndex(uint256 _ProdactId) internal view returns (uint256 index, bool found) {
        prodactById[] storage userProducts = marketplus[msg.sender];
        for (uint256 i = 0; i < userProducts.length; i++) {
            if (userProducts[i].id == _ProdactId) {
                return (i, true);
            }
        }
        return (0, false);
    }

    function editProdact(uint256 _ProdactId, string memory _name, string memory _description, uint256 _stok, uint256 _price, string[] memory _prodactImage) external {
        (uint256 index, bool found) = findTheProdactIndex(_ProdactId);
        require(found, "Product Not Found");

        prodactById storage target = marketplus[msg.sender][index];
        target.prodacts.name = _name;
        target.prodacts.description = _description;
        target.prodacts.stok = _stok;
        target.prodacts.price = _price;
        target.prodacts.prodactImage = _prodactImage;
    }

    function removeProdact(uint256 _ProdactId) external {
        (uint256 index, bool found) = findTheProdactIndex(_ProdactId);
        require(found, "Product Not Found");

        prodactById[] storage userProducts = marketplus[msg.sender];
        for (uint256 i = index; i < userProducts.length - 1; i++) {
            userProducts[i] = userProducts[i + 1];
        }

        userProducts.pop();
    }

    function getMerchantProducts(address _merchant) external view returns (prodactById[] memory) {
        return marketplus[_merchant];
    }
}
