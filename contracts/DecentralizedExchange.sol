// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "./SimpleToken.sol";

contract DecentralizedExchange {

    IERC20 public token;

    string public constant name = "Decentralized Exchange";

    event Bought(uint256 amount);
    event Sold(uint256 amount);

    constructor() {
        token = new SimpleToken();
    }

    /* The user can send Ether and get tokens in exchange  */
    function buy() payable public {
       uint256 amountTobuy = msg.value;
       uint256 dexBalance = token.balanceOf(address(this));
       require(amountTobuy > 0, "You need to send some Ether");
       require(amountTobuy <= dexBalance, "Not enough tokens in the reserve");
       token.transfer(msg.sender, amountTobuy);
       emit Bought(amountTobuy);
    }

    /* The user can decide to send tokens to get ether back */
    function sell(uint256 amount) payable public {
      require(amount > 0, "You need to sell at least some tokens");
      uint256 allowance = token.allowance(msg.sender, address(this));
      require(allowance >= amount, "Check the token allowance");
      token.transferFrom(msg.sender, address(this), amount);
      payable(msg.sender).transfer(amount);
      emit Sold(amount);
    }

}
