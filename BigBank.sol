// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface IBank {
    function deposit() external payable;
    function getBalance(address depositor) external view returns(uint);
    function withdraw(uint8 amount) external ; 
}
contract Bank is IBank {
    address public owner;
    mapping (address => uint256) public deposits;
    address[] public top3Bankers;
    constructor() payable {
        owner = msg.sender;
    }
    

    function deposit() public payable virtual {
        deposits[msg.sender] += msg.value;
        top3banker(msg.sender);
    }
    function getBalance(address depositor) public view returns(uint) {
        return deposits[depositor];
    }
    function withdraw(uint8 amount) public {
        require(owner == msg.sender, "you meiyou quanxian");
        uint256 balance = address(this).balance;
        require(amount < balance, "zhuanzhang wuxiao");
        payable(owner).transfer(amount);

    }
    function top3banker(address depositor) internal {
        bool intop3 = false;
        for(uint8 i = 0; i < top3Bankers.length; i++) {
            if(depositor == top3Bankers[i]) {
                intop3 = true;
                break;
            }
        }
        if (!intop3) {
            top3Bankers.push(depositor);
        }
        for(uint8 i = 0; i < top3Bankers.length; i++) {
            for(uint8 j=0; j < i; j++) {
                if(deposits[top3Bankers[i]] < deposits[top3Bankers[j]]) {
                    address temp = top3Bankers[i];
                    top3Bankers[i] = top3Bankers[j];
                    top3Bankers[j] = temp;
                }
            }
        }
        if(top3Bankers.length > 3) {
            top3Bankers.pop();
        }
    }
    function getTop3() public view returns (address[] memory){
        return top3Bankers;
    }
}
contract BigBank is Bank {
    modifier leastAmount() {
        require(msg.value >= 0.001 ether, "you mei you quanxian");
        _;
    }
    function deposit() public payable virtual override leastAmount {
        super.deposit();
    } 
    function transferOwnership(address newOwner) external {
        require(msg.sender == owner, "you mei quanxian");
        owner = newOwner;

    }
}
interface IBigBank {
    function withdraw(uint256 amount) external;
}
contract Admin {
    address public Owner;
    IBigBank public bigBank;
    constructor() {
        Owner = msg.sender;
    }
    modifier onlyOwner() {
        require(msg.sender == Owner, "you mei quanxian");
        _;
    }
    function setBigBankAddress(address _bigBankAddress) public onlyOwner {
        bigBank = IBigBank(_bigBankAddress);
    }


   // function adminWithdraw(IBank bank) public onlyOwner {
    //    bank.withdraw(uint8 amount);
    //}
    //function withdrawAll() external  payable onlyOwner{
    //    require (bigBank != address(0), "you mei quanxian");
    //    bigBank.withdraw(address(this).balance);
        
    //}
    function withdraw(uint256 amount) public onlyOwner {
        bigBank.withdraw(amount);
    }

}