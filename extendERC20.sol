// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
//import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}


interface ITokenReceiver {
    function tokensReceived(address from, uint256 amount) external returns (bool);
}
contract ExtendedERC20 {
    string public name; 
    string public symbol; 
    uint8 public decimals; 

    uint256 public totalSupply; 

    mapping (address => uint256) balances; 

    mapping (address => mapping (address => uint256)) allowances; 

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        name = "MyToken"; 
        symbol = "AAA"; 
        decimals = 18; 
        totalSupply = 100000000 * 10 ** uint256(decimals);

        balances[msg.sender] = totalSupply;  
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];    
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value, "ERC20: transfer amount exceeds balance");

        balances[msg.sender] -= _value;    
        balances[_to] += _value;   

        emit Transfer(msg.sender, _to, _value);  
        return true;   
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balances[_from] >= _value, "ERC20: transfer amount exceeds balance");
        require(allowances[_from][msg.sender] >= _value,"ERC20: transfer amount exceeds allowance");

        balances[_from] -= _value; 
        balances[_to] += _value; 

        allowances[_from][msg.sender] -= _value;
        
        emit Transfer(_from, _to, _value); 
        return true; 
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowances[msg.sender][_spender] = _value; 
        emit Approval(msg.sender, _spender, _value); 
        return true; 
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowances[_owner][_spender];
    }
    

    function transferWithCallback(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value, "ERC20: transfer amount exceeds balance");
        require(_to != address(0), "ERC20: transfer to the zero address");
        
        balances[msg.sender] -= _value;
        balances[_to] += _value;

        emit Transfer(msg.sender, _to, _value);
        
        // 如果接收方是合约，调用其tokensReceived方法
        if (isContract(_to)) {
            try ITokenReceiver(_to).tokensReceived(msg.sender, _value) returns (bool) {
                // 回调成功
            } catch {
                // 回调失败，但不回滚交易
            }
        }
        
        return true;
    }

    function isContract(address _adr) private view returns(bool) {
        uint32 size;
        assembly {
            size := extcodesize(_adr)
        }
        return(size > 0);
    }
    
}

contract TokenBank {
    IERC20 public token;
    mapping(address => uint256) public balances;

    // 定义事件
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    constructor(address _tokenAddress) {
        token = IERC20(_tokenAddress);
    }

    function deposit(uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        balances[msg.sender] += amount;
        
        // 触发存款事件
        emit Deposit(msg.sender, amount);
    }

    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        require(token.transfer(msg.sender, amount), "Transfer failed");
        
        // 触发取款事件
        emit Withdraw(msg.sender, amount);
    }
    function balanceOf(address _user) external view returns (uint256) {
        return balances[_user];
    }
}

contract TokenBankV2 is TokenBank, ITokenReceiver {
    // 扩展的ERC20代币合约地址
    ExtendedERC20 public extendedToken;
    
    // 构造函数，设置扩展的ERC20代币合约地址
    constructor(address _tokenAddress) TokenBank(_tokenAddress) {
        extendedToken = ExtendedERC20(_tokenAddress);
    }
    
    // 实现tokensReceived接口，处理通过transferWithCallback接收到的代币
    function tokensReceived(address from, uint256 amount) external override returns (bool) {
        // 检查调用者是否为代币合约
        require(msg.sender == address(token), "TokenBankV2: caller is not the token contract");
        
        // 更新用户的存款记录
        balances[from] += amount;
        
        // 触发存款事件
        emit Deposit(from, amount);
        
        return true;
    }
}