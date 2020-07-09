// SPDX-License-Identifier: MIT

pragma solidity >=0.4.25 <0.7.0;

import "./RelayerCallSender.sol";

contract CounterModuleV2 is RelayerCallSender {
    uint256 private _value;
    address public sender;

    function set(uint256 value) external {
        _value = value;
        sender = _getRelayedCallSender();
    }

    function getValue() external view returns (uint256) {
        return _value;
    }
}
