// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GymToken is ERC20("GymToken", "G"), Ownable(msg.sender) {
    
    struct product {
        string name;
        string description;
        uint256 stok;
        uint256 price;
        string[] productImage;
    }
    
    struct productById {
        uint256 id;
        product products;
    }
    
    mapping(address => productById[]) internal marketplus;

    event SubscriptionPaid(address indexed client, address indexed GymOwner, uint256 amount);

    function rewardTokenSubscription(address recipient, uint256 amount) external onlyOwner {
        _mint(recipient, amount);
    }

    function paySubscription(address GymOwner, uint256 amount) external {
        address clinet = msg.sender;
        transferFrom(clinet, GymOwner, amount);
        emit SubscriptionPaid(clinet, GymOwner, amount);
    }

    function addProduct(uint256 _ProductId, string memory _name, string memory _description, uint256 _stok, uint256 _price, string[] memory _productImage) external {
        product memory newProduct = product(_name, _description, _stok, _price, _productImage);
        productById memory p = productById(_ProductId, newProduct);
        marketplus[msg.sender].push(p);
    }

    function findTheProductIndex(uint256 _ProductId) internal view returns (uint256 index, bool found) {
        productById[] storage userProducts = marketplus[msg.sender];
        for (uint256 i = 0; i < userProducts.length; i++) {
            if (userProducts[i].id == _ProductId) {
                return (i, true);
            }
        }
        return (0, false);
    }

    function editProduct(uint256 _ProductId, string memory _name, string memory _description, uint256 _stok, uint256 _price, string[] memory _productImage) external {
        (uint256 index, bool found) = findTheProductIndex(_ProductId);
        require(found, "Product Not Found");

        productById storage target = marketplus[msg.sender][index];
        target.products.name = _name;
        target.products.description = _description;
        target.products.stok = _stok;
        target.products.price = _price;
        target.products.productImage = _productImage;
    }

    function removeProduct(uint256 _ProductId) external {
        (uint256 index, bool found) = findTheProductIndex(_ProductId);
        require(found, "Product Not Found");

        productById[] storage userProducts = marketplus[msg.sender];
        for (uint256 i = index; i < userProducts.length - 1; i++) {
            userProducts[i] = userProducts[i + 1];
        }

        userProducts.pop();
    }

    function getMerchantProducts(address _merchant) external view returns (productById[] memory) {
        return marketplus[_merchant];
    }
}
