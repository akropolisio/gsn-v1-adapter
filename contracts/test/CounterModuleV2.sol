// SPDX-License-Identifier: MIT

pragma solidity ^0.5.12;

import "../GSNContext.sol";

contract CounterModuleV2 is GSNContext {
    uint256 private _value;
    address private _sender;

    function setValue(uint256 value) external {
        _value = value;
        _sender = _msgSender();
    }

    function getValue() external view returns (uint256) {
        return _value;
    }

    function getSender() external view returns (address) {
        return _sender;
    }
}
