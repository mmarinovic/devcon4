pragma solidity ^0.4.23;

contract MultiSig {
  
  address[] public owners;
  mapping(address => bool) public validOwners;
  uint256 public required;

  uint256 public transactionCount;
  mapping(uint256 => Transaction) public transactions;
  mapping(uint256 => mapping(address => bool)) public confirmations;

  struct Transaction{
    address destination;
    uint256 amount;
    bool isExecuted;
    bytes data;
  }

  constructor(address[] _owners, uint256 _required) public {
      require(_owners.length > 0);
      require(_required > 0);
      require(_required <= _owners.length);

      owners = _owners;
      for(uint i = 0; i < _owners.length; i++){
        validOwners[_owners[i]] = true;
      }
      required = _required;
  }

  function addTransaction(address _destination, uint256 _amount, bytes _data) internal returns (uint256){
    require(_destination != address(0));

    Transaction memory newTransaction = Transaction({
      destination: _destination,
      amount: _amount,
      isExecuted: false,
      data: _data
    });

    uint transactionID = transactionCount;
    transactions[transactionID] = newTransaction;
    transactionCount ++;

    return transactionID;
  }

  function confirmTransaction(uint256 _transactionId) public {
    require(validOwners[msg.sender] == true);
    require(transactions[_transactionId].destination != address(0));
    require(confirmations[_transactionId][msg.sender] == false);
    confirmations[_transactionId][msg.sender] = true;

    if(isConfirmed(_transactionId)){
      executeTransaction(_transactionId);
    }
  }

  function getConfirmations(uint256 _transactionId) public view returns (address[]){

    uint count = 0;
  
    for(uint i = 0; i< owners.length; i++){
      if(confirmations[_transactionId][owners[i]]){
        count ++;
      }
    }

    address[] memory confirmed = new address[](count);
    uint index = 0;

    for(uint j = 0; j< owners.length; j++){
      if(confirmations[_transactionId][owners[j]]){
        confirmed[index] = owners[j];
        index ++;
      }
    }
    
    return confirmed;
  }

  function submitTransaction(address _destination, uint _amount, bytes _data) public {
    uint256 id = addTransaction(_destination, _amount, _data);
    confirmTransaction(id);
  }

  function() public payable {

  }

  function isConfirmed(uint256 _transactionId) public constant returns (bool) {
    address[] memory confirms = getConfirmations(_transactionId);
    return (confirms.length >= required);
  }

  function executeTransaction(uint256 _transactionId) public {
    require(isConfirmed(_transactionId));
    require(!transactions[_transactionId].isExecuted);
    
    transactions[_transactionId].isExecuted = true;
    require(transactions[_transactionId].destination.call.value(transactions[_transactionId].amount)(transactions[_transactionId].data));
  }

  function getTransactionCount(bool _executed, bool _pending) public view returns (uint){

    uint count = 0;
    for(uint i = 0; i< transactionCount; i++){
      if(transactions[i].isExecuted && _executed){
        count++;
      }else if(!transactions[i].isExecuted && _pending){
        count++;
      }
    }

    return count;
  }

  function getTransactionIds(bool _pending, bool _executed) public view returns (uint256[]){

    uint count = 0;
    for(uint i = 0; i< transactionCount; i++){
      if(transactions[i].isExecuted && _executed){
        count++;
      }else if(!transactions[i].isExecuted && _pending){
        count++;
      }
    }

    uint256[] memory ids = new uint256[](count);
    uint256 index = 0;

    for(uint j = 0; j < transactionCount; j++){
      if(transactions[j].isExecuted && _executed){
        ids[index] = j + 1;
        index++;
      }else if(!transactions[j].isExecuted && _pending){
        ids[index] = j + 1;
        index++;
      }
    }

    return ids;
  }

  function getOwners() public view returns (address[]){
    address[] memory result = new address[](owners.length);
    for(uint i = 0; i<owners.length; i++){
      result[i] = owners[i];
    }
    return result;
  }
}