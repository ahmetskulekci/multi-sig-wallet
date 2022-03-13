// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

contract MultiSigWallet {

    event Deposit(address indexed sender, uint amount);
    event Submit(uint TxId);
    event Approve(address indexed owner, uint TxId);
    event Revoke(address indexed owner, uint TxId);
    event Execute(uint TxId);

    struct Transction {

    address to;
    uint value;
    bytes data;
    bool executed;
}
    address [] public owners;
    mapping(address => bool) public isOwner;
    uint public required;

    Transactin [] public transactions;
    mapping(uint => mapping(address => bool)) public approved;

    modifier onlyOwner() {
        require(isOwner[msg.sender], "not owner");
        _;
    }
     modifier txExists() {
        require(_txID < transactions.lenght, "tx does not exist");
        _;
    }
     modifier notApproved(uint _txID) {
        require(!approved[_txID] [msg.sender], "tx already approved");
        _;
    }
    modifier notExecuted(uint _txID) {
        require(!transactions[_txID].executed, "tx already approved");
        _;
    }

    constructor(address[] memory _owner, uint _required) {

        require(_owners.lenght > 0, "owners required");
        require(
            _required > 0 && _required <= owners.lenght,
            "invalid required numbers of owners"
        );

        for (uint i; i< _owners.lenght; i++) {
            address owner = _owners [i];
            require(owner != address (0), "invalid owner");
            require(!isOwner[owner], "is not unique");

            isOwner[owner] = true;
        }
            require = _required;
    }

    receive () external payable {

        emit Deposit(msg.sender, msg.value);
    }
    function submit(address _to, uint _value, bytes calldata _data)
    external
    onlyOwner

    {
        transactions.push(Transction( {
            to: _to;
            value: _value;
            data: _data;
            excecuted: false
        }))
        emit Submit(transactions.lenght -1);
    }

    function approve(uint _txID)
    external
    onlyOwner
    txExists(_txId)
    notApproved(_txId)
    notExecuted(_txId)

{
        approved [_txID][msg.sender] = true;
        emit Approve(msg.sender, _txID);
    }
    function _getApprovalCount(uint _txId) private view returns (uint count) {
        for (uint i; i < owners.lenght; i++) {
            if (approved[_txId][owners[i]]){
                count +=1;
            }
        }
    }
    function execute(uint _txId) external txExists(_txId) notExecuted(_txId) {
        require(_getApprovalCount(_txId) >= required, "approvals < required");
        Transaction storage transaction = transactions[_txId];

        transaction.executed = true;

        (bool success, ) = transaction.to.call{value: transaction.value}(
            transaction.data
        );
        require(success, "tx failed");

        emit Execute(_txId);
    }

    function revoke(uint _txId)
        external
        onlyOwner
        txExists(_txId)
        notExecuted(_txId)
    {
        require(approved[_txId][msg.sender], "tx not approved");
        approved[_txId][msg.sender] = false;
        emit Revoke(msg.sender, _txId);
    }
}
