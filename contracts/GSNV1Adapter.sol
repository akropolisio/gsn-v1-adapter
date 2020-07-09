// SPDX-License-Identifier: MIT

pragma solidity >=0.4.25 <0.7.0;

import "@openzeppelin/contracts-ethereum-package/contracts/GSN/GSNRecipientSignature.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/access/AccessControl.sol";

contract GSNV1Adapter is
    GSNRecipientSignatureUpgradeSafe,
    AccessControlUpgradeSafe
{
    bytes32 private constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    struct Target {
        string targetName;
        address targetAddress;
    }

    mapping(bytes => Target) private _targets;

    function initilize(address trustedSigner) public initializer {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MANAGER_ROLE, _msgSender());
        __GSNRecipientSignature_init(trustedSigner);
    }

    fallback() external payable {
        _delegate(_msgData());
    }

    // solhint-disable-next-line no-empty-blocks
    receive() external payable {}

    // GETTERS

    function getManager() external pure returns (bytes32) {
        return MANAGER_ROLE;
    }

    function getTargetName(bytes memory encodedFunction)
        external
        view
        returns (string memory)
    {
        return _targets[encodedFunction].targetName;
    }

    function getTargetAddress(bytes memory encodedFunction)
        external
        view
        returns (address)
    {
        return _targets[encodedFunction].targetAddress;
    }

    // SETTERS

    // TODO onlyOwner modifier
    function setTarget(
        bytes memory encodedFunctionName,
        string memory targetName,
        address targetAddress
    ) external returns (bool) {
        require(hasRole(MANAGER_ROLE, _msgSender()), "Caller is not a manager");
        _targets[encodedFunctionName] = Target({
            targetName: targetName,
            targetAddress: targetAddress
        });
        return true;
    }

    // RELAYHUB ACCESS

    function deposit() public payable {
        IRelayHub(getHubAddr()).depositFor{ value: msg.value }(address(this));
    }

    // TODO onlyOwner modifier
    function withdraw(uint256 amount, address payable payee) public {
        _withdrawDeposits(amount, payee);
    }

    // RELAYHUB CALLS

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

    // MSG

    function _msgSender()
        internal
        virtual
        override(ContextUpgradeSafe, GSNRecipientUpgradeSafe)
        view
        returns (address payable)
    {
        return ContextUpgradeSafe._msgSender();
    }

    function _msgData()
        internal
        virtual
        override(ContextUpgradeSafe, GSNRecipientUpgradeSafe)
        view
        returns (bytes memory)
    {
        return GSNRecipientUpgradeSafe._msgData();
    }

    // PRIVATE FUNCTIONS

    function _encodedFunctionName() private view returns (bytes memory) {
        bytes memory actualData = new bytes(4);

        for (uint256 i = 0; i < 4; ++i) {
            actualData[i] = _msgData()[i];
        }

        return actualData;
    }

    function _delegate(bytes memory) private returns (bool, bytes memory) {
        return
            _targets[_encodedFunctionName()].targetAddress.call{
                value: msg.value
            }(_msgData());
    }
}
