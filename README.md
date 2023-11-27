# Multi Signature Wallet



Multi signature wallet, also known as a multisig wallet, is a type of cryptocurrency wallet that requires multiple signatures to authorize a transaction. Unlike traditional wallets that require only a single private key, multi signature wallets distribute control over the funds among multiple parties. This adds an extra layer of security, as it reduces the risk of a single point of failure.

Multi signature wallets utilize a combination of public and private keys. To initiate a transaction, a predetermined number of signatures is required. For example, a 3-of-5 multi signature wallet would require three out of five authorized parties to sign the transaction. This ensures that no single party can unilaterally access or transfer the funds.



### Function Workflow

#### 1. isUnique ()

```s
    function isUnique(address[] memory arr) private pure returns (bool) {
        for (uint256 i = 0; i < arr.length - 1; i++) {
            for (uint256 j = i + 1; j < arr.length; j++) {
                require(arr[i] != arr[j], "Duplicate address.");
            }
        }
        return true;
    }
```

#### 2. proposeTx ()

```s
        function proposeTx(
        uint256 _deadline,
        address _txAddress,
        uint256 _value,
        bytes memory _txData
    ) external onlySigners {
        require(_deadline > block.timestamp, "Time out");

        Tx memory _tx = Tx({
            proposer: msg.sender,
            confirmations: 0,
            txAddress: _txAddress,
            executed: false,
            deadline: _deadline,
            value: _value,
            txData: _txData
        });

        nonceToTx[nonce] = _tx;
        nonce++;
    }
```

#### 3. confirmTx ()

```s
    function confirmTx(uint256 _nonce) external onlySigners {
        require(_nonce < nonce, "Not exists.");
        require(txConfirmers[_nonce][msg.sender] == false, "Already approved.");
        require(nonceToTx[_nonce].deadline > block.timestamp, "Time out");
        require(nonceToTx[_nonce].executed == false, "Already executed");

        nonceToTx[_nonce].confirmations++;
        txConfirmers[_nonce][msg.sender] = true;
    }
 ```   
 #### 4. deleteTx ()

```s
    function deleteTx(uint256 _nonce) external onlySigners {
        require(_nonce < nonce, "Not exists.");
        require(nonceToTx[_nonce].executed == false, "Already executed");
        require(nonceToTx[_nonce].proposer == msg.sender, "Not tx owner.");
        require(
            nonceToTx[_nonce].confirmations < requiredConfirmations,
            "Already confirmed."
        );

        nonceToTx[_nonce].executed = true;
    }
 ```   
  #### 5. revokeTx ()

```s
    function revokeTx(uint256 _nonce) external onlySigners {
        require(_nonce < nonce, "Not exists.");
        require(
            txConfirmers[_nonce][msg.sender] == true,
            "Already non approved."
        );
        require(nonceToTx[_nonce].deadline > block.timestamp, "Time out");
        require(nonceToTx[_nonce].executed == false, "Already executed");

        nonceToTx[_nonce].confirmations--;
        txConfirmers[_nonce][msg.sender] = false;
    }
 ```  
   #### 6. executeTx ()

```s
       function executeTx(uint256 _nonce) external onlySigners returns (bool) {
        require(_nonce < nonce, "Not exists.");
        require(nonceToTx[_nonce].deadline > block.timestamp, "Time out");
        require(
            nonceToTx[_nonce].confirmations >= requiredConfirmations,
            "Already confirmed."
        );
        require(nonceToTx[_nonce].executed == false, "Already executed");

        require(nonceToTx[_nonce].value <= address(this).balance);

        nonceToTx[_nonce].executed = true;

        (bool txSuccess, ) = (nonceToTx[_nonce].txAddress).call{
            value: nonceToTx[_nonce].value
        }(nonceToTx[_nonce].txData);

        if (!txSuccess) nonceToTx[_nonce].executed = false;

        return txSuccess;
    }
 ```  

 ```  