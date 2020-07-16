pragma solidity ^0.5.0;

import "@openzeppelin/upgrades/contracts/Initializable.sol";

/**
 * @dev Base GSN context contract: includes the {IRelayRecipient} interface
 * and enables GSN support on all contracts in the inheritance tree.
 *
 * TIP: This contract is abstract. The functions {acceptRelayedCall},
 *  {_preRelayedCall}, and {_postRelayedCall} are not implemented and must be
 * provided by derived contracts. See the
 * xref:ROOT:gsn-strategies.adoc#gsn-strategies[GSN strategies] for more
 * information on how to use the pre-built {GSNRecipientSignature} and
 * {GSNRecipientERC20Fee}, or how to write your own.
 */
contract GSNAdapterContext is Initializable {
    function initializeGSNAdapterContext(address gsnAdapter) public {
        _upgradeGSNAdapter(gsnAdapter);
    }

    function setDefaultAdapter() public {
        _upgradeGSNAdapter(address(0));
    }

    // Default GSNAdapter address, deployed on mainnet and all testnets at the same address
    address private _gsnAdapter;

    /**
     * @dev Emitted when a contract changes its {IGSNAdapter} contract to a new one.
     */
    event GSNAdapterChanged(
        address indexed oldGSNAdapter,
        address indexed newGSNAdapter
    );

    /**
     * @dev Returns the address of the {IGSNAdapter} contract for this recipient.
     */
    function getGSNAdapterAddr() public view returns (address) {
        return _gsnAdapter;
    }

    /**
     * @dev Switches to a new {IGSNAdapter} instance. This method is added for future-proofing: there's no reason to not
     * use the default instance.
     *
     * IMPORTANT: After upgrading, the {GSNRecipient} will no longer be able to receive relayed calls from the old
     * {IGSNAdapter} instance. Additionally, all funds should be previously withdrawn via {_withdrawDeposits}.
     */
    function _upgradeGSNAdapter(address newGSNAdapter) internal {
        address currentGSNAdapter = _gsnAdapter;
        require(
            newGSNAdapter != address(0),
            "GSNAdapterContext: new GSNAdapter is the zero address"
        );
        require(
            newGSNAdapter != currentGSNAdapter,
            "GSNAdapterContext: new GSNAdapter is the current one"
        );

        emit GSNAdapterChanged(currentGSNAdapter, newGSNAdapter);

        _gsnAdapter = newGSNAdapter;
    }

    /**
     * @dev Replacement for msg.sender. Returns the actual sender of a transaction: msg.sender for regular transactions,
     * and the end-user for GSN relayed calls (where msg.sender is actually `GSNAdapter`).
     *
     * IMPORTANT: Contracts derived from {GSNRecipient} should never use `msg.sender`, and use {_msgSender} instead.
     */
    function _msgSender() internal view returns (address payable) {
        if (msg.sender != _gsnAdapter) {
            return msg.sender;
        } else {
            return _getRelayedCallSender();
        }
    }

    /**
     * @dev Replacement for msg.data. Returns the actual calldata of a transaction: msg.data for regular transactions,
     * and a reduced version for GSN relayed calls (where msg.data contains additional information).
     *
     * IMPORTANT: Contracts derived from {GSNRecipient} should never use `msg.data`, and use {_msgData} instead.
     */
    function _msgData() internal view returns (bytes memory) {
        if (msg.sender != _gsnAdapter) {
            return msg.data;
        } else {
            return _getRelayedCallData();
        }
    }

    function _getRelayedCallSender()
        private
        pure
        returns (address payable result)
    {
        // We need to read 20 bytes (an address) located at array index msg.data.length - 20. In memory, the array
        // is prefixed with a 32-byte length value, so we first add 32 to get the memory read index. However, doing
        // so would leave the address in the upper 20 bytes of the 32-byte word, which is inconvenient and would
        // require bit shifting. We therefore subtract 12 from the read index so the address lands on the lower 20
        // bytes. This can always be done due to the 32-byte prefix.

        // The final memory read index is msg.data.length - 20 + 32 - 12 = msg.data.length. Using inline assembly is the
        // easiest/most-efficient way to perform this operation.

        // These fields are not accessible from assembly
        bytes memory array = msg.data;
        uint256 index = msg.data.length;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            // Load the 32 bytes word from memory with the address on the lower 20 bytes, and mask those.
            result := and(
                mload(add(array, index)),
                0xffffffffffffffffffffffffffffffffffffffff
            )
        }
        return result;
    }

    function _getRelayedCallData() private pure returns (bytes memory) {
        // GSNAdapter appends the sender address at the end of the calldata, so in order to retrieve the actual msg.data,
        // we must strip the last 20 bytes (length of an address type) from it.

        uint256 actualDataLength = msg.data.length - 20;
        bytes memory actualData = new bytes(actualDataLength);

        for (uint256 i = 0; i < actualDataLength; ++i) {
            actualData[i] = msg.data[i];
        }

        return actualData;
    }
}
