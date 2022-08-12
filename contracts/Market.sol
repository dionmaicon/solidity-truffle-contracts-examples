// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract Market {
  string public name;
  address payable public owner;
  uint public productCount = 0;
  mapping( uint => Product) public products;


  struct Product {
      uint id;
      string name;
      uint price;
      uint balance;
  }

  event ProductCreated(
    uint id,
    string name,
    uint price,
    uint balance
  );

  event ProductPurchased(
    uint id,
    string name,
    uint price,
    uint quantity,
    address owner
  );

  constructor() {
    name = 'Market';
    owner = payable(msg.sender);
  }

  function createProduct(string memory _name, uint _balance, uint _price) public {
    // Create the products
    require(bytes(_name).length > 0);
    require(_price > 0);
    require(_balance > 0);

    // Increment productCount
    productCount ++;
    products[productCount] = Product(productCount, _name, _price, _balance);

      // Trigger an event
    emit ProductCreated(productCount, _name, _price, _balance);
  }

  function purchaseProduct(uint _id, uint _quantity) public payable{
    //Fetch the products
    Product memory _product = products[_id];
    //Require section
    require(_product.id > 0 && _product.id <= productCount);
    require(_product.balance > _quantity);
    require(msg.value >= _product.price * _quantity);
    require(owner != msg.sender);

    _product.balance = _product.balance - _quantity;

    //Save Products
    products[_id] = _product;

    //Pay the owner
    payable(owner).transfer(msg.value);
    //trigger an event
    emit  ProductPurchased(productCount, _product.name, msg.value, _quantity, msg.sender);
  }

  function removeProduct(uint _id) public {
    require(msg.sender == owner);
    delete products[_id];
  }
}
