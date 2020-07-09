// SPDX-License-Identifier: MIT

pragma solidity >=0.4.25 <0.7.0;

import "./RelayerCallSender.sol";

contract CounterModuleV1 is RelayerCallSender {
    uint256 private _value;
    address public sender;

    function increase() public {
        _value += 1;
        sender = _getRelayedCallSender();
    }

    function getValue() external view returns (uint256) {
        return _value;
    }
}
