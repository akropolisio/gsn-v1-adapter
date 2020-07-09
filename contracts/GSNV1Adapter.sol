// SPDX-License-Identifier: MIT

pragma solidity >=0.4.25 <0.7.0;

import "@openzeppelin/contracts-ethereum-package/contracts/GSN/GSNRecipientSignature.sol";

contract GSNV1Adapter is GSNRecipientSignatureUpgradeSafe {
    address public target;

    function initilize(address trustedSigner, address _target)
        public
        initializer
    {
        target = _target;
        __GSNRecipientSignature_init(trustedSigner);
    }

    fallback() external {
        (bool success, bytes memory result) = target.call(msg.data);
        (success, result);
    }

    // RELAYHUB CALLS

    // We won't do any pre or post processing, so leave _preRelayedCall and _postRelayedCall empty
    function _preRelayedCall(bytes memory)
        internal
        virtual
        override
        returns (bytes32)
    {}

    function _postRelayedCall(
        bytes memory,
        bool,
        uint256,
        bytes32
    ) internal virtual override {}
}
