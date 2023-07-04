// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "../src/MultiStake.sol";

contract MultiStakeFuzzTest is Test {
    MultiStake multiStake;
    uint256 public totalSubmissions;
    uint256 public totalExecutions;
    address[] owners = new address[](5);

    function setUp() public {
        owners[0] = address(1);
        owners[1] = address(2);
        owners[2] = address(3);
        owners[3] = address(4);
        owners[4] = address(5);

        multiStake = new MultiStake(owners, 2);
        totalSubmissions = 0;
        totalExecutions = 0;
    }

    function test_SetUp() public {
        assertTrue(_getOwnersLength() == 5);
        assertEq(totalExecutions, 0);
        assertEq(totalSubmissions, 0);
        emit log_named_bytes("Owners", abi.encode(multiStake.owners));
    }

    function testFuzz_Submit(
        address _to,
        uint96 _value,
        bytes calldata _data
    ) public {
        vm.prank(address(1));
        multiStake.submit(_to, _value, _data);
        vm.prank(address(2));
        multiStake.submit(_to, _value, _data);
        vm.prank(address(3));
        multiStake.submit(_to, _value, _data);
        vm.prank(address(4));
        multiStake.submit(_to, _value, _data);
        vm.prank(address(5));
        multiStake.submit(_to, _value, _data);
    }

    /** HELPER FUNCTIONS */
    function _getOwnersLength() public view returns (uint256) {
        return owners.length;
    }
}
