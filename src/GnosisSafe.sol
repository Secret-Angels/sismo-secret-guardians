/// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract Enum {
    enum Operation {
        Call,
        DelegateCall
    }
}

interface GnosisSafe {
    /// @dev Allows a Module to execute a Safe transaction without any further confirmations.
    /// @param to Destination address of module transaction.
    /// @param value Ether value of module transaction.
    /// @param data Data payload of module transaction.
    /// @param operation Operation type of module transaction.
    function execTransactionFromModule(address to, uint256 value, bytes calldata data, Enum.Operation operation)
        external
        returns (bool success);

    /// @param module Module address
    function enableModule(address module) external;

    /// @notice Adds the owner owner to the Safe and updates the threshold to _threshold.
    /// @dev This can only be done via a Safe transaction.
    /// @param owner New owner address.
    /// @param _threshold New threshold.
    function addOwnerWithThreshold(address owner, uint256 _threshold) external;
}
