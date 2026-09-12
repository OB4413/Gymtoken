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
        product product;
    }
    
    struct sales {
        uint256 id;
        string productName;
        address client;
        uint256 quantity;
        uint256 time;
        uint256 totalPrice;
        bool status;
    }
    
    struct purchases {
        uint256 id;
        string productName;
        address gymOwner;
        uint256 quantity;
        uint256 time;
        uint256 totalPrice;
    }

    mapping(address => productById[]) internal marketplace;

    mapping(address => sales[]) internal salesGymOwner;
    mapping(address => purchases[]) internal purchasesClinet;


    event SubscriptionPaid(address indexed client, address indexed GymOwner, uint256 amount);
    event ProductBought(address indexed client, address indexed GymOwner, uint256 ProductId, uint256 quantity);
    event changeStatusSale(address indexed  gymOwner, sales sale, bool delivered);
    event addProductSucc(address indexed GymMarketplace, string productName, string description, uint256 stok, uint256 price);
    event editProductSucc(address indexed GymMarketplace, string  name, string  description, uint256 stok, uint256 price);
    event removeProductSucc(address indexed GymMarketplace, uint256 ProductId);

    function rewardTokenSubscription(address recipient, uint256 amount) external onlyOwner {
        _mint(recipient, amount);
    }

    function paySubscription(address GymOwner, uint256 amount) external {
        address clinet = msg.sender;
        _transfer(clinet, GymOwner, amount);
        emit SubscriptionPaid(clinet, GymOwner, amount);
    }

    function addProduct(uint256 _ProductId, string memory _name, string memory _description, uint256 _stok, uint256 _price, string[] memory _productImage) external {
        product memory newProduct = product(_name, _description, _stok, _price, _productImage);
        productById memory p = productById(_ProductId, newProduct);
        marketplace[msg.sender].push(p);

        emit addProductSucc(msg.sender, _name, _description, _stok, _price);
    }

    function findTheProductIndex(address addrMarketplace, uint256 _ProductId) internal view returns (uint256 index, bool found) {
        productById[] storage userProduct = marketplace[addrMarketplace];
        for (uint256 i = 0; i < userProduct.length; i++) {
            if (userProduct[i].id == _ProductId) {
                return (i, true);
            }
        }
        return (0, false);
    }

    function editProduct(uint256 _ProductId, string memory _name, string memory _description, uint256 _stok, uint256 _price, string[] memory _productImage) external {
        (uint256 index, bool found) = findTheProductIndex(msg.sender, _ProductId);
        require(found, "Product Not Found");

        productById storage target = marketplace[msg.sender][index];
        target.product.name = _name;
        target.product.description = _description;
        target.product.stok = _stok;
        target.product.price = _price;
        target.product.productImage = _productImage;

        emit editProductSucc(msg.sender, _name, _description, _stok, _price);
    }

    function removeProduct(uint256 _ProductId) external {
        (uint256 index, bool found) = findTheProductIndex(msg.sender ,_ProductId);
        require(found, "Product Not Found");

        productById[] storage userProduct = marketplace[msg.sender];
        for (uint256 i = index; i < userProduct.length - 1; i++) {
            userProduct[i] = userProduct[i + 1];
        }

        userProduct.pop();

        emit removeProductSucc(msg.sender, _ProductId);
    }

    function getMerchantProduct(address _merchant) external view returns (productById[] memory) {
        return marketplace[_merchant];
    }

    function    buyProduct(address addMarketplace, uint256 _ProductId, uint256 _quantity) external {
        require(_quantity > 0, "Quantity must be greater than 0");
        (uint256 index, bool found) = findTheProductIndex(addMarketplace, _ProductId);
        require(found, "Product Not Found");

        uint256 totalPrice = marketplace[addMarketplace][index].product.price * _quantity;
        string memory productName = marketplace[addMarketplace][index].product.name;
        address _clinet = msg.sender;

        require(marketplace[addMarketplace][index].product.stok >= _quantity, "_quantity is not avilible is stell just marketplace[addMarketplace][index].product.stok");

        require(balanceOf(_clinet) >= totalPrice, "Price is not correct");
        marketplace[addMarketplace][index].product.stok -= _quantity;

        _transfer(_clinet, addMarketplace, totalPrice);
        emit ProductBought(_clinet, addMarketplace, _ProductId, _quantity);

        sales memory newSales = sales(salesGymOwner[addMarketplace].length , productName, _clinet, _quantity, block.timestamp, totalPrice, false);
        purchases memory newPurchases = purchases(purchasesClinet[_clinet].length, productName, addMarketplace, _quantity, block.timestamp, totalPrice);

        salesGymOwner[addMarketplace].push(newSales);
        purchasesClinet[_clinet].push(newPurchases);
    }

    function    getsales() external view returns (sales[] memory) {
        return salesGymOwner[msg.sender];
    }

    function    getPurchases() external view returns (purchases[] memory) {
        return purchasesClinet[msg.sender];
    }

    function changeStatus(uint256 _id) external {
        sales storage sale = salesGymOwner[msg.sender][_id];
        sale.status = true;

        emit changeStatusSale(msg.sender ,salesGymOwner[msg.sender][_id], true);
    }
}
