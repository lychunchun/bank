// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract Bank{
    address public owner;
    mapping (address => uint256) public deposits;
    address[] public top3Bankers;
    constructor(){
        owner = msg.sender;
    }
    

    function deposit() public payable {
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