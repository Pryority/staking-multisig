// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "../src/MultiStake.sol";

contract MultiStakeFuzzTest is Test {
    MultiStake multiStake;
    uint256 public totalSubmissions;
    uint256 public totalExecutions;
    address[] owners = new address[](5);

    event Approved(uint256 indexed id, address indexed approver, bool isApproved);

    function setUp() public {
        owners[0] = address(1);
        owners[1] = address(2);
        owners[2] = address(3);
        owners[3] = address(4);
        owners[4] = address(5);

        multiStake = new MultiStake(owners, 2);
        totalSubmissions = 0;
        totalExecutions = 0;

        vm.deal(address(multiStake), 5 ether);
    }

    function test_SetUp() public {
        assertTrue(_getOwnersLength() == 5);
        assertEq(totalExecutions, 0);
        assertEq(totalSubmissions, 0);
        emit log_named_bytes("Owners", abi.encode(multiStake.owners));
    }

    function test_Approve() public {
        vm.startPrank(address(1));
        multiStake.submit(address(0xB0B), 1 ether, hex"01");
        multiStake.approve(0);
        vm.stopPrank();
        vm.startPrank(address(2));
        multiStake.approve(0);
        vm.stopPrank();
        vm.startPrank(address(3));
        multiStake.approve(0);
        vm.stopPrank();
        vm.startPrank(address(4));
        multiStake.approve(0);
        vm.stopPrank();
        vm.startPrank(address(5));
        multiStake.approve(0);
        vm.stopPrank();

        vm.startPrank(address(1));
        vm.expectRevert("Tx does not exist");
        multiStake.approve(1);
        vm.stopPrank();

        vm.startPrank(address(0xB0B));
        vm.expectRevert("Not owner");
        multiStake.approve(0);
        vm.stopPrank();
    }

    function testFuzz_Submit(address to, uint96 value, bytes calldata data) public {
        vm.prank(address(1));
        multiStake.submit(to, value, data);
        vm.prank(address(2));
        multiStake.submit(to, value, data);
        vm.prank(address(3));
        multiStake.submit(to, value, data);
        vm.prank(address(4));
        multiStake.submit(to, value, data);
        vm.prank(address(5));
        multiStake.submit(to, value, data);
    }

    function test_EndToEnd() public {
        // Prank an owner
        address prankedOwner = owners[0];
        vm.prank(prankedOwner);

        // Submit a transaction
        address to = address(0xFAB);
        uint96 value = 1 ether;
        bytes memory data = hex"";
        multiStake.submit(to, value, data);
        totalSubmissions++;

        // Approve the transaction
        for (uint256 i = 0; i < 3; i++) {
            vm.prank(owners[i]);
            multiStake.approve(totalSubmissions - 1);
            emit Approved(totalSubmissions - 1, owners[i], true);
        }

        // emit log_array(owners);

        // Execute the transaction
        vm.prank(prankedOwner);
        multiStake.execute(totalSubmissions - 1);
        totalExecutions++;
        // Verify the execution
        assertEq(totalExecutions, 1);
        assertEq(totalSubmissions, 1);
        assertTrue(address(0xFAB).balance == value);
    }

    /**
     * HELPER FUNCTIONS
     */
    function _getOwnersLength() public view returns (uint256) {
        return owners.length;
    }
}
