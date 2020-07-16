// SPDX-License-Identifier: MIT

pragma solidity ^0.5.12;

import "../GSNAdapterContext.sol";

contract CounterModuleV1 is GSNAdapterContext {
    uint256 private _value;
    address private _sender;

    function increase() public {
        _value += 1;
        _sender = _msgSender();
    }

    function getValue() external view returns (uint256) {
        return _value;
    }

    function getSender() external view returns (address) {
        return _sender;
    }
}
