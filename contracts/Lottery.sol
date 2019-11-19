pragma solidity >=0.4.22 <0.6.0;

contract Lottery {
    
    // 定義抽獎卷的金額
    uint public constant TICKET_PRICE = 0.01 ether;
    
    // 定義合約的擁有者
    address public owner;
    
    // 定義樂透的開始與結束時間
    uint public _startTime;
    uint public _endTime;
    
    // 遊戲狀態控制
    bool private _isGameStarted;
    bool private _isGameEnded;
    
    // 玩家購買紀錄表
    // 玩家在遊戲中身份是以address型態出現，需要用mapping來記錄「有哪個地址已經買了入場卷」
    mapping (address=>bool) playerBook;
    
    // 遊戲結束時需要抽出一個地址，需要另外紀錄全部有加入遊戲的地址
    address[] playersAddress;
    
    // 定義成功買票後的事件
    event BuyTicket(address indexed _buyer, uint _spent, uint _buyTime);
    // 定義提款後的事件
    
    // 建構合約
    constructor() public {
        owner = msg.sender;
    }
    
    // 定義一些高權限事項的修改器
    modifier onlyOwnerCanDoThis() {
        require(msg.sender==owner);
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
    
    // 定義匿名的收錢function
    function () onlyHumanCanDoThis external payable {}
    
    // 定義遊戲開始時，需要執行的行為
    function startGame() internal {}
    
    // 定義遊戲結束時，需要執行的行為
    function endGame() internal {}
    
    // 定義買抽獎卷的function
    function buyTicket() onlyHumanCanDoThis public {}
    
    // 遊戲結束後，選擇贏家的function
    function selectWinner() public pure returns(address) {}
    
    // 遊戲結束後，分配以太幣給贏家
    function sendProfitToWinner() internal {}
    
    // 遊戲結束後，管理者可選擇是否要讓合約自殺
    function suicide() onlyOwnerCanDoThis public {}
    
    
}
