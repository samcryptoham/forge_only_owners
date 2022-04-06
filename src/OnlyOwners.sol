// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

contract OnlyOwners{

    mapping(address => uint) public ownerToId;

    constructor (address[] memory _owners){
        require(_owners.length > 0, "Owners required");
        // Assign an ID to a owner address, this way the owner can update the address to a new one without breaking multi-sig functionality
        for (uint i = 0; i < _owners.length; i++){
            address owner = _owners[i];
            require(owner != address(0), "Null owner not allowed");
            require(!(ownerToId[owner] > 0), "Owner is not unique");
            ownerToId[owner] = i+1;
        }
    }

    /**** MODIFIERS ****/
    modifier onlyOwner(){
        require(_isOwner(msg.sender), "Not owner");
        _;
    }


    /**** FUNCTIONS ****/
    function _isOwner(address addr) internal view returns(bool){
        return ownerToId[addr] > 0;
    }

    // This function takes a new address, it the checks the new address
    // Then it retrieves the msg.sender's current id,
    // it then changes the msg.senders id to 0
    // and updates the newAddress id to the msg.senders former id.
    function changeOwnership(address newAddress) external onlyOwner{
        require(newAddress != address(0), "Null owner is not allowed");
        require(!_isOwner(newAddress), "New address is already owner");

        uint id = ownerToId[msg.sender];

        // Remove the msg.sender address from owner list
        ownerToId[msg.sender] = 0;

        // Set the new address as the owner of msg.sender id.
        ownerToId[newAddress] = id;

    }
}
