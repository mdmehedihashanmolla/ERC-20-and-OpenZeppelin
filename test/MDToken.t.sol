// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import {Test, console} from "forge-std/Test.sol";
import {MDToken} from "../src/MDToken.sol";

contract MDTokenTest is Test {
    MDToken token;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    address owner = address(1);
    address user = address(2);

    function setUp() public {
        vm.prank(owner);
        token = new MDToken(1000 * 10 ** 18);
    }

    function testInitialSupply() public view {
        uint256 expectedSupply = token.totalSupply();
        assertEq(expectedSupply, token.balanceOf(owner));
    }

    function testTransfer() public {
        vm.prank(owner);
        token.transfer(user, 100 * 10 ** 18);
        assertEq(token.balanceOf(user), 100 * 10 ** 18);
    }

    function testTransferToZeroAddress() public {
        vm.prank(owner);
        vm.expectRevert("Invalid address: transfer to the zero address");
        token.transfer(address(0), 100 * 10 ** 18);
    }

    function testTransferInsufficientBalance() public {
        vm.prank(user);
        vm.expectRevert("Insufficient balance");
        token.transfer(owner, 100 * 10 ** 18);
    }

    function testApproveAndTransferFrom() public {
        vm.prank(owner);
        token.approve(user, 200 * 10 ** 18);

        vm.prank(user);
        token.transferFrom(owner, user, 150 * 10 ** 18);

        assertEq(token.balanceOf(user), 150 * 10 ** 18);
        assertEq(token.allowance(owner, user), 50 * 10 ** 18);
    }

    function testTransferFromExceedAllowance() public {
        vm.prank(owner);
        token.approve(user, 100 * 10 ** 18);

        vm.prank(user);
        vm.expectRevert("Allowance exceeded");
        token.transferFrom(owner, user, 150 * 10 ** 18);
    }

    function testApproveZeroAddress() public {
        vm.prank(owner);
        vm.expectRevert("Invalid address: approve to the zero address");
        token.approve(address(0), 100 * 10 ** 18);
    }

    function testTransferEvent() public {
        vm.prank(owner);
        vm.expectEmit(true, true, false, true); // Check for `Transfer` event
        emit Transfer(owner, user, 100 * 10 ** 18); // Emit the expected event
        token.transfer(user, 100 * 10 ** 18);
    }

    function testApproveEvent() public {
        vm.prank(owner);
        vm.expectEmit(true, true, false, true); // Check for `Approval` event
        emit Approval(owner, user, 200 * 10 ** 18); // Emit the expected event
        token.approve(user, 200 * 10 ** 18);
    }

    function testDecimalHandling() public {
        vm.prank(owner);
        token.transfer(user, 1);
        assertEq(token.balanceOf(user), 1);
    }
}
