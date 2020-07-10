// SPDX-License-Identifier: MIT

pragma solidity >=0.4.25 <0.7.0;

import "./RelayedCallSender.sol";

contract CounterModuleV1 is RelayedCallSender {
    uint256 private _value;
    address private _sender;

    function increase() public {
        _value += 1;
        _sender = _getRelayedCallSender();
    }

    function getValue() external view returns (uint256) {
        return _value;
    }

    function getSender() external view returns (address) {
        return _sender;
    }
}
