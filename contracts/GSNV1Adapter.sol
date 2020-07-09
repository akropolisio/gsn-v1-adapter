// SPDX-License-Identifier: MIT

pragma solidity >=0.4.25 <0.7.0;

import "@openzeppelin/contracts-ethereum-package/contracts/GSN/GSNRecipient.sol";

contract GSNV1Adapter is GSNRecipientUpgradeSafe {
    struct Target {
        string targetName;
        address targetAddress;
    }

    mapping(bytes4 => Target) private _targets;

    function initilize() external initializer {
        // QUESTION Proxy
        __Context_init_unchained();
        __GSNRecipient_init_unchained();
    }

    fallback() external {
        (bool success, bytes memory result) = _targets[_encodedFunctionName()]
            .targetAddress
            .call(msg.data);
        (success, result);
    }

    // GETTERS

    function getTargetName(bytes4 encodedFunction)
        external
        view
        returns (string memory)
    {
        return _targets[encodedFunction].targetName;
    }

    function getTargetAddress(bytes4 encodedFunction)
        external
        view
        returns (address)
    {
        return _targets[encodedFunction].targetAddress;
    }

    // SETTERS

    // TODO onlyOwner modifier
    function setTarget(
        bytes4 encodedFunctionName,
        string memory targetName,
        address targetAddress
    ) external returns (bool) {
        _targets[encodedFunctionName] = Target({
            targetName: targetName,
            targetAddress: targetAddress
        });
        return true;
    }

    // RELAYHUB ACCESS

    function deposit() external payable {
        IRelayHub(getHubAddr()).depositFor{ value: msg.value }(address(this));
    }

    // TODO onlyOwner modifier
    function withdraw(uint256 amount, address payable payee) external {
        _withdrawDeposits(amount, payee);
    }

    // RELAYHUB CALLS

    // TODO Check Original Sender Signature (canRelay or ECDSA OZ)
    function acceptRelayedCall(
        address relay,
        address from,
        bytes calldata encodedFunction,
        uint256 transactionFee,
        uint256 gasPrice,
        uint256 gasLimit,
        uint256 nonce,
        bytes calldata approvalData,
        uint256 maxPossibleCharge
    ) external override view returns (uint256, bytes memory) {
        (
            relay,
            from,
            encodedFunction,
            transactionFee,
            gasPrice,
            gasLimit,
            nonce,
            approvalData,
            maxPossibleCharge
        );

        return _approveRelayedCall();
    }

    // We won't do any pre or post processing, so leave _preRelayedCall and _postRelayedCall empty
    function _preRelayedCall(bytes memory context)
        internal
        override
        returns (bytes32)
    {
        (context);
    }

    function _postRelayedCall(
        bytes memory context,
        bool,
        uint256 actualCharge,
        bytes32
    ) internal override {
        (context, actualCharge);
    }

    // PRIVATE FUNCTIONS

    function _encodedFunctionName() private returns (bytes4) {
        // TODO encodedFunctionName
    }
}
