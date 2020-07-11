// SPDX-License-Identifier: MIT

pragma solidity >=0.4.25 <0.7.0;

import "@openzeppelin/contracts-ethereum-package/contracts/GSN/GSNRecipientSignature.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/access/AccessControl.sol";

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

    /**
     * @dev Sets the values for {trustedSigner} and {admin}.
     *
     * All two of these values are immutable: they can only be set once during
     * initialization.
     *
     * @param trustedSigner Address of the trusted signer.
     *
     * @param admin Address of the admin.
     */
    function initilize__0xb373a41f(address trustedSigner, address admin)
        public
        initializer
    {
        _setupRole(DEFAULT_ADMIN_ROLE, admin);
        _setupRole(MANAGER_ROLE, admin);
        __GSNRecipientSignature_init(trustedSigner);
    }

    fallback() external payable {
        _delegate();
    }

    // solhint-disable-next-line no-empty-blocks
    receive() external payable {}

    /**
     * @dev Returns hash of the manager role.
     */
    function getManagerRole__0xb373a41f() external pure returns (bytes32) {
        return MANAGER_ROLE;
    }

    /**
     * @dev Returns name of the target.
     *
     * @param encodedFunction First 4 bytes of the function hash.
     *
     * @return String name of the target.
     */
    function getTargetName__0xb373a41f(bytes memory encodedFunction)
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
    function getTargetAddress__0xb373a41f(bytes memory encodedFunction)
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
        bytes memory encodedFunction,
        string memory targetName,
        address targetAddress
    ) external onlyManager returns (bool) {
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
        IRelayHub(getHubAddr()).depositFor{ value: msg.value }(address(this));
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
        onlyManager
        returns (bool)
    {
        _withdrawDeposits(amount, payee);
        return true;
    }

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
