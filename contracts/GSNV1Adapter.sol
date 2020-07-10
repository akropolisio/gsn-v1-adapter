// SPDX-License-Identifier: MIT

pragma solidity >=0.4.25 <0.7.0;

import "@openzeppelin/contracts-ethereum-package/contracts/GSN/GSNRecipientSignature.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/access/AccessControl.sol";

// bytes4(keccak256(bytes("GSNV1Adapter"))) == 0xb373a41f

contract GSNV1Adapter is
    GSNRecipientSignatureUpgradeSafe,
    AccessControlUpgradeSafe
{
    bytes32 private constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    modifier onlyManager() {
        require(hasRole(MANAGER_ROLE, _msgSender()), "Caller is not a manager");
        _;
    }

    struct Target {
        string targetName;
        address targetAddress;
    }

    mapping(bytes => Target) private _targets;

    function initilize__0xb373a41f(address trustedSigner) public initializer {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MANAGER_ROLE, _msgSender());
        __GSNRecipientSignature_init(trustedSigner);
    }

    fallback() external payable {
        _delegate();
    }

    // solhint-disable-next-line no-empty-blocks
    receive() external payable {}

    // GETTERS

    function getManager__0xb373a41f() external pure returns (bytes32) {
        return MANAGER_ROLE;
    }

    function getTargetName__0xb373a41f(bytes memory encodedFunction)
        external
        view
        returns (string memory)
    {
        return _targets[encodedFunction].targetName;
    }

    function getTargetAddress__0xb373a41f(bytes memory encodedFunction)
        external
        view
        returns (address)
    {
        return _targets[encodedFunction].targetAddress;
    }

    // SETTERS

    function setTarget__0xb373a41f(
        bytes memory encodedFunctionName,
        string memory targetName,
        address targetAddress
    ) external onlyManager returns (bool) {
        _targets[encodedFunctionName] = Target({
            targetName: targetName,
            targetAddress: targetAddress
        });
        return true;
    }

    // RELAYHUB ACCESS

    function deposit__0xb373a41f() external payable {
        IRelayHub(getHubAddr()).depositFor{ value: msg.value }(address(this));
    }

    function withdraw__0xb373a41f(uint256 amount, address payable payee)
        external
        onlyManager
    {
        _withdrawDeposits(amount, payee);
    }

    // RELAYHUB CALLS

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
        return GSNRecipientUpgradeSafe._msgSender();
    }

    function _msgData()
        internal
        virtual
        override(ContextUpgradeSafe, GSNRecipientUpgradeSafe)
        view
        returns (bytes memory)
    {
        if (msg.sender != getHubAddr()) {
            return
                abi.encodePacked(
                    GSNRecipientUpgradeSafe._msgData(),
                    _msgSender()
                );
        } else {
            return ContextUpgradeSafe._msgData();
        }
    }

    // PRIVATE FUNCTIONS

    function _encodedFunctionName() private view returns (bytes memory) {
        bytes memory actualData = new bytes(4);

        for (uint256 i = 0; i < 4; ++i) {
            actualData[i] = _msgData()[i];
        }

        return actualData;
    }

    function _delegate() private returns (bool, bytes memory) {
        return
            _targets[_encodedFunctionName()].targetAddress.call{
                value: msg.value
            }(_msgData());
    }
}
