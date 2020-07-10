// SPDX-License-Identifier: MIT

pragma solidity >=0.4.25 <0.7.0;

import "./RelayedCallSender.sol";

contract CounterModuleV2 is RelayedCallSender {
    uint256 private _value;
    address private _sender;

    function setValue(uint256 value) external {
        _value = value;
        _sender = _getRelayedCallSender();
    }

    function getValue() external view returns (uint256) {
        return _value;
    }

    function getSender() external view returns (address) {
        return _sender;
    }
}
