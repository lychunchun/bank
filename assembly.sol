// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyWallet {
    string public name;
    mapping (address => bool) private approved;
    address public owner; // This variable will now primarily be managed via assembly

    // 定义 owner 变量的存储插槽位置
    // string name 在 slot 0
    // mapping approved 不占用顺序插槽
    // owner 在 slot 1
    uint256 private constant OWNER_STORAGE_SLOT = 1;

    modifier auth {
        address currentOwner;
        // 使用内联汇编从存储插槽读取 owner 地址
        assembly {
            currentOwner := sload(OWNER_STORAGE_SLOT)
        }
        require (msg.sender == currentOwner, "Not authorized");
        _;
    }

    constructor(string memory _name) {
        name = _name;
        // 在构造函数中，owner 变量的设置仍然可以使用 Solidity 语法
        // 因为这是初始化，编译器会正确处理其存储。
        // 或者，也可以使用汇编进行设置：
        assembly {
            sstore(OWNER_STORAGE_SLOT, caller()) // caller() 获取 msg.sender
        }
    }

    function transferOwernship(address _addr) auth public { // 显式添加 public
        address currentOwner;
        // 使用内联汇编获取当前的 owner 地址进行校验
        assembly {
            currentOwner := sload(OWNER_STORAGE_SLOT)
        }

        require(_addr != address(0), "New owner is the zero address");
        require(currentOwner != _addr, "New owner is the same as the old owner");

        // 使用内联汇编将新的 owner 地址写入存储插槽
        assembly {
            sstore(OWNER_STORAGE_SLOT, _addr)
        }
    }

    // 添加一个 getter 函数，用于通过汇编获取 owner 地址，以验证设置是否成功
    function getOwnerViaAssembly() public view returns (address) {
        address currentOwner;
        assembly {
            currentOwner := sload(OWNER_STORAGE_SLOT)
        }
        return currentOwner;
    }
}
