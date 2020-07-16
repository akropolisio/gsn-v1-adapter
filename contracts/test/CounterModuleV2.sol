// SPDX-License-Identifier: MIT

pragma solidity ^0.5.12;

import "../GSNAdapterContext.sol";

contract CounterModuleV2 is GSNAdapterContext {
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
