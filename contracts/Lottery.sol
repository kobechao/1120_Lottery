pragma solidity >=0.4.22 <0.6.0;

contract Lottery {

    // owner of the contract
    address payable public owner;
    
    uint public _startTime;
    uint public _endTime;

    bool public _isGameStarted;
    bool public _isGameEnded;

    // 紀錄每個開獎號碼所有投入的玩家列表
    mapping (uint=>address payable[]) playerData;

    // 紀錄每個開獎號碼所有投入的金額
    mapping (uint=>uint) indexTotalValue;
    
    // 玩家投入金額
    mapping (address=>uint) balances;

    // record of players who buy ticket
    // players show as address, need mapping to record "which address already buy ticket"
    mapping (address=>playerStatus) playerBook;
    
    struct playerStatus {
        bool isjoin;
        uint index;
    }
    
    // record all the addresses
    address payable[] playersAddress;

    // event: the only way to communicate with outside
    // indexed: speed up the search rate
    event Bet(address indexed _buyer, uint _spent, uint _buyTime);
    event Winner(address indexed _winner, uint _amount,uint a, uint b, uint c, string msg);
    
    uint public finalWinIndex;
    
    // start contract
    constructor() public {
        owner = msg.sender;
        startGame();
    }

    // 定義一些高權限事項的修改器 (pre-process, check, verify)
    modifier onlyOwnerCanDoThis() {
        require(msg.sender==owner, "onlyOwnerCanDoThis");
        _;
    }

    // 每個會改變state的函式，必須確認呼叫者必須是一般的地址(external address)，而不是合約地址(contract address)
    modifier onlyHumanCanDoThis() {
        address _addr = msg.sender;
        uint256 _codeLength;

        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "Addresses not owned by human are forbidden");
        _;
    }

    function () onlyHumanCanDoThis external payable {
    }

    function startGame() internal {
        _isGameStarted = true;
        _startTime = now;
        _endTime = _startTime + 10 minutes;
    }

    // exceed end time
    function endGame() internal {
        _isGameEnded = true;
        _isGameStarted = false;
        sendProfitToWinners();
    }
    
    // function getPlayerStatus() public view returns(bool, uint) {
    //     return (playerBook[msg.sender].isjoin, playerBook[msg.sender].index);
    // }
    
    function bet(uint _index) public payable {
        
        // avoid 0 because _index default value 0
        // require(_index>=1 && _index<=9);
        require(_index>=1 && _index<=3);

        require(_isGameStarted == true);
        require(_isGameEnded == false);
        require(playerBook[msg.sender].isjoin == false || playerBook[msg.sender].index == _index, "Already bought");
        
        if(playerBook[msg.sender].isjoin == false){
            playerData[_index].push(msg.sender);
        }

        playerBook[msg.sender].isjoin = true;
        playerBook[msg.sender].index = _index;

        uint value = msg.value;
        indexTotalValue[_index] += value;
        balances[msg.sender] += value;
        emit Bet(msg.sender, msg.value, now);
        
        if(now >= _endTime)
            endGame();
    }
    
    function getNum(uint _number) public view returns (uint, address payable[]  memory){
        address payable[] memory _addrs = playerData[_number];
        return (indexTotalValue[_number], _addrs);
    }
    
    function selectWinIndex() public view returns(uint) {
        return uint(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty)))%3)+1;
    }

    function sendProfitToWinners() internal {
        // address payable winner = selectWinner();
        uint winIndex = selectWinIndex();
        finalWinIndex = winIndex;
        
        uint amount = 0;
        // for(uint i=1; i<=9; i++)
        //     amount += indexTotalValue[i];

       for(uint i=1; i<=3; i++)
            amount += indexTotalValue[i];
  
        address payable[] memory winners = playerData[winIndex];
        for(uint j=0; j<winners.length; j++){
            address payable win = winners[j];
            uint profit = amount*balances[win]/indexTotalValue[winIndex];
            win.transfer(profit);
            emit Winner(win, profit, amount, balances[win], indexTotalValue[winIndex], "Winner Found!");
            
            //prevent reentrancy attack
            profit = 0;            
        }
    }
}
