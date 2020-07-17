// SPDX-License-Identifier: MIT

pragma solidity ^0.5.12;

import "@openzeppelin/contracts-ethereum-package/contracts/GSN/GSNRecipientSignature.sol";

import "@openzeppelin/contracts-ethereum-package/contracts/ownership/Ownable.sol";

/**
 * @title GSNV1Adapter
 * @dev Implements delegation of calls to other
 * contracts via GSN, with proper forwarding of
 * return values and bubbling of failures.
 *
 * All functions in this implementation have a
 * `0xb373a41f` postfix, that prevents names from intersecting
 * with the target contract.
 *
 * @notice 0xb373a41f == bytes4(keccak256(bytes("GSNV1Adapter")))
 */
contract GSNV1Adapter is Ownable, GSNRecipientSignature {
    struct Target {
        string targetName;
        address targetAddress;
    }

    mapping(bytes4 => Target) private _targets;

    /**
     * @dev Sets the value for {trustedSigner}.
     *
     * This value are immutable: it can only be set once during
     * initialization.
     *
     * @param trustedSigner Address of the trusted signer.
     *
     */
    function initilize__0xb373a41f(address trustedSigner) public initializer {
        GSNRecipientSignature.initialize(trustedSigner);
        Ownable.initialize(msg.sender);
    }

    function() external payable {
        _delegate();
    }

    /**
     * @dev Returns name of the target.
     *
     * @param encodedFunction First 4 bytes of the function hash.
     *
     * @return String name of the target.
     */
    function getTargetName__0xb373a41f(bytes4 encodedFunction)
        external
        view
        returns (string memory)
    {
        return _targets[encodedFunction].targetName;
    }

    /**
     * @dev Returns address of the target.
     *
     * @param encodedFunction First 4 bytes of the function hash.
     *
     * @return Address of the target.
     */
    function getTargetAddress__0xb373a41f(bytes4 encodedFunction)
        external
        view
        returns (address)
    {
        return _targets[encodedFunction].targetAddress;
    }

    /**
     * @dev Sets target struct in mapping.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * @param encodedFunction First 4 bytes of the function hash.
     *
     * @param targetName String name of the target.
     *
     * @param targetAddress Address of the target.
     *
     * @return Boolean value indicating whether the operation succeeded.
     */
    function setTarget__0xb373a41f(
        bytes4 encodedFunction,
        string calldata targetName,
        address targetAddress
    ) external onlyOwner returns (bool) {
        _targets[encodedFunction] = Target({
            targetName: targetName,
            targetAddress: targetAddress
        });
        return true;
    }

    /**
     * @dev See {IRelayHub-depositFor}.
     * https://github.com/OpenZeppelin/openzeppelin-contracts-ethereum-package
     *
     * @return Boolean value indicating whether the operation succeeded.
     */
    function deposit__0xb373a41f() external payable returns (bool) {
        IRelayHub(getHubAddr()).depositFor.value(msg.value)(address(this));
        return true;
    }

    /**
     * @dev Withdraws the recipient's deposits in `RelayHub`.
     *
     * @param amount The amount of eth that is transferred to the recipient's address.
     *
     * @param payee Recipient address.
     *
     * @return Boolean value indicating whether the operation succeeded.
     */
    function withdraw__0xb373a41f(uint256 amount, address payable payee)
        external
        onlyOwner
        returns (bool)
    {
        _withdrawDeposits(amount, payee);
        return true;
    }

    function _preRelayedCall(bytes memory context) internal returns (bytes32) {
        (context);
    }

    function _postRelayedCall(
        bytes memory context,
        bool,
        uint256 actualCharge,
        bytes32
    ) internal {
        (context, actualCharge);
    }

    function _msgSender() internal view returns (address payable) {
        return GSNRecipient._msgSender();
    }

    function _msgData() internal view returns (bytes memory) {
        if (msg.sender != getHubAddr()) {
            return abi.encodePacked(GSNRecipient._msgData(), _msgSender());
        } else {
            return Context._msgData();
        }
    }

    function _delegate() private returns (bool, bytes memory) {
        (bool success, bytes memory result) = _targets[msg.sig]
            .targetAddress
            .call
            .value(msg.value)(_msgData());

        if (!success)
            assembly {
                revert(add(result, 32), result)
            }

        return (success, result);
    }
}
