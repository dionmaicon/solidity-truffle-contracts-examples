// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

// Original from SCP
// https://www.youtube.com/watch?v=8ja72g_Dac4
// https://solidity-by-example.org/app/multi-sig-wallet/

contract MultiSigWallet {
    event Deposit(address indexed sender, uint amount);
    event Approve(address indexed owner, uint indexed transactionId);
    event Revoke(address indexed owner, uint indexed transactionId);
    event Submit(uint indexed transactionId);
    event Execute(uint indexed transactionId);
   
    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool executed;
    }

    address[] public owners;
    mapping(address => bool ) public isOwner;
    uint public required;

    Transaction[] public transactions;
    mapping(uint => mapping(address => bool)) public approved;


    constructor(address[] memory _owners, uint8 _required) {
        _init(_owners, _required);
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }
    
    modifier onlyOwner {
        require(isOwner[msg.sender], "not authorized" );
        _;
    }

    modifier txExists(uint _txId) {
        require(_txId < transactions.length, "Tx doesnt exist");
        _;
    }

    modifier notApproved(uint _txId) {
        require(!approved[_txId][msg.sender], "Tx already approved");
        _;
    }

    modifier notExecuted(uint _txId) {
        require(!transactions[_txId].executed, "Tx already approved");
        _;
    }

    function _init(address[] memory _owners, uint8 _required) private {
        require(_owners.length > 0, "owners required");
        require(
            _required > 0 && _required <= _owners.length,
            "invalid required number of owners"
        );

        for (uint i; i < _owners.length; i++) {
            address owner = _owners[i];

            require(owner != address(0), "invalid owner" );
            require(!isOwner[owner], "owner is not unique");

            isOwner[owner] = true;
            owners.push(owner);
        }
    }

     function submit(
        address _to,
        uint _value,
        bytes  calldata _data
    ) 
        external 
        onlyOwner 
    {
        transactions.push(
            Transaction({ to: _to, value: _value, data: _data, executed: false })
        );
        emit Submit(transactions.length - 1);
    }

    function approve(uint _txId) 
        external 
        onlyOwner 
        txExists(_txId)
        notApproved(_txId)
        notExecuted(_txId)
    {
        approved[_txId][msg.sender] = true;
        emit Approve(msg.sender, _txId);
    }

    function _getApprovalCount(uint _txId) private view returns (uint count) {
        for (uint i; i < owners.length; i++) {
            if (approved[_txId][owners[i]]) {
                count += 1;
            }
        }
    }

    function execute(uint _txId) 
        external
        onlyOwner()
        txExists(_txId) 
        notExecuted(_txId) 
    {
        require(_getApprovalCount(_txId) >= required, "Not enough approvals");
        Transaction storage transaction = transactions[_txId];
        
        (bool success, ) = transaction.to.call{ value: transaction.value }(
            transaction.data
        );
        
        require(success, "tx failed");

        transaction.executed == true;

        emit Execute(_txId);
    }

    function revoke(uint _txId)
        external
        onlyOwner()
        txExists(_txId) 
        notExecuted(_txId) 
    {
        require(approved[_txId][msg.sender], "tx not approved");
        approved[_txId][msg.sender] = false;
        emit Revoke(msg.sender, _txId);
    }
}

contract TestContract {
    uint public i;

    function callMe(uint j) public {
        i += j;
    }

    function getData() public pure returns (bytes memory) {
        return abi.encodeWithSignature("callMe(uint256)", 123);
    }
}
