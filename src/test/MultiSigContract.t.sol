// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "ds-test/test.sol";
import "../MultiSigContract.sol";
import "forge-std/stdlib.sol";
import "forge-std/Vm.sol";
import "forge-std/console.sol";


contract MultisigContractTest is DSTest {
    Vm public constant vm = Vm(HEVM_ADDRESS);
    address ownerA = address(0xA);
    address ownerB = address(0xB);

    address[] allOwners = [ownerA, ownerB];

    MultiSigContract msContract;

    function setUp() public {
        msContract = new MultiSigContract(allOwners);
    }

    // **** TEST SET PROPOSAL TRUE **** //
    // Expect the test to fail if the sender of the transaction isn't an owner
    function testRevertNotOwnerSetProposalTrue() public {
        vm.expectRevert("Not owner");
        msContract.setProposalTrue();
    }
    function testFuzzyRevertNotOwnerSetProposalTrue(address proposer) public {
        vm.expectRevert("Not owner");
        vm.prank(proposer);
        msContract.setProposalTrue();
    }

    function testRevertAlreadyTrueSetProposalTrue() public {
        vm.prank(ownerB);
        msContract.setProposalTrue();
        vm.startPrank(ownerA);
        msContract.confirmProposalUpdate(0);
        vm.expectRevert("Proposal is already true");
        msContract.setProposalTrue();
    }

    // **** TEST SET PROPOSAL FALSE **** //
    function testRevertNotOwnerSetProposalFalse() public {
        vm.expectRevert("Not owner");
        msContract.setProposalFalse();
    }
    function testFuzzyRevertNotOwnerSetProposalFalse(address proposer) public {
        vm.expectRevert("Not owner");
        vm.prank(proposer);
        msContract.setProposalFalse();
    }

    function testRevertAlreadyTrueSetProposalFalse() public {
        vm.expectRevert("Proposal is already false");
        vm.prank(ownerB);
        msContract.setProposalFalse();
    }

    // **** TEST CONFIRM PROPOSAL UPDATE **** //
    function testConfirmProposalWrongIndex(uint index) public {
        vm.expectRevert("Proposal state update doesn't exists");
        vm.prank(ownerB);
        msContract.confirmProposalUpdate(index);
    }
    function testConfirmProposalNotOwner(address addr) public {
        vm.expectRevert("Not owner");
        vm.prank(addr);
        msContract.confirmProposalUpdate(1);
    }

    // Mocking functionality
    function testMockFunction() public {
        vm.prank(ownerA);
        assertEq(msContract.mockFunction(10), 2000);
    }

    function setMockFunctionReturnValue(uint val) public{
        vm.mockCall(
            address(msContract),
            abi.encodeWithSelector(msContract.mockFunction.selector),
            abi.encode(val));

    }

    function testMockFunctionMockReturnValue() public {
        setMockFunctionReturnValue(10);
        vm.prank(ownerA);
        assertEq(msContract.mockFunction(100), 10);
    }

    function testFuzzyMockFunctionMockReturnValue(uint val) public {
        setMockFunctionReturnValue(val);
        vm.prank(ownerA);
        assertEq(msContract.mockFunction(100), val);
    }
}
