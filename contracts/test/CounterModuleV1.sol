// SPDX-License-Identifier: MIT

pragma solidity >=0.4.25 <0.7.0;

import "./RelayerCallSender.sol";

contract CounterModuleV1 is RelayerCallSender {
    uint256 public value;
    address public sender;

    function increase() public {
        value += 1;
        sender = _getRelayedCallSender();
    }
}
