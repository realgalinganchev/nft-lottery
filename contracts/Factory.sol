// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/utils/Create2.sol";

contract Factory {
    event MinimalProxyCreated(address minimalProxy);

    function computeAddress(uint256 salt, address implementation)
        public
        view
        returns (address)
    {
        return
            Create2.computeAddress(
                keccak256(abi.encodePacked(salt)),
                keccak256(getContractCreationCode(implementation)),
                address(this)
            );
    }

    function deploy(uint256 salt, address implementation) public {
        address minimalProxy = Create2.deploy(
            0,
            keccak256(abi.encodePacked(salt)),
            getContractCreationCode(implementation)
        );
        emit MinimalProxyCreated(minimalProxy);
    }

    function getContractCreationCode(address logic)
        internal
        pure
        returns (bytes memory)
    {
        bytes10 creation = 0x3d602d80600a3d3981f3;
        bytes10 prefix = 0x363d3d373d3d3d363d73;
        bytes20 targetBytes = bytes20(logic);
        bytes15 suffix = 0x5af43d82803e903d91602b57fd5bf3;
        return abi.encodePacked(creation, prefix, targetBytes, suffix);
    }
}
