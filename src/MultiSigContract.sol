// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import './OnlyOwners.sol';
import "forge-std/console.sol";

contract MultiSigContract is OnlyOwners {

    bool public proposal = false;

    struct UpdateContractState {
        bool proposal; // We want to change the proposal value to the other state (false if true and true if false)
        uint numConfirmations;
        bool accepted;
    }
    UpdateContractState[] public contractStateUpdateProposals;
    mapping(uint => mapping(uint => bool)) public contractStateUpdate;

    uint confirmationsRequired;

    constructor (address[] memory _owners)
        OnlyOwners(_owners){
        confirmationsRequired = _owners.length;
    }


    function _createProposalUpdate(bool state) private {
        uint index = contractStateUpdateProposals.length;
        contractStateUpdateProposals.push(
            UpdateContractState({
                proposal: state,
                numConfirmations: 1,
                accepted: false
            })
        );
        uint ownerId = ownerToId[msg.sender];
        // Voting YES on the update contract state proposal with the ownerID
        contractStateUpdate[index][ownerId] = true;
    }

    function setProposalTrue() external onlyOwner {
        require(!proposal, "Proposal is already true");
        _createProposalUpdate(true);
    }

    function setProposalFalse() external onlyOwner {
        require(proposal, "Proposal is already false");
        _createProposalUpdate(false);
    }

    function mockFunction(uint val) external view onlyOwner returns (uint) {
        require(val >= 10, "Value needs to be greater than 10");
        return val*200;
    }

    function confirmProposalUpdate(uint _index) external onlyOwner {
        uint ownerId = ownerToId[msg.sender];
        require(_index < contractStateUpdateProposals.length, "Proposal state update doesn't exists");
        require(!contractStateUpdate[_index][ownerId], "You've already accepted this update");
        require(!contractStateUpdateProposals[_index].accepted, "This state change have already been accepted");

        UpdateContractState storage state = contractStateUpdateProposals[_index];
        state.numConfirmations += 1;
        contractStateUpdate[_index][ownerId] = true;

        if (state.numConfirmations == confirmationsRequired){
            proposal = state.proposal;
        }

    }
}
