// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

// Original from SCP

contract AccessControl {

    event GrantAccess(bytes32 role, address account);
    event RevokeAccess(bytes32 role, address account);
    // 0xdf8b4c520ffe197c5343c6f5aec59570151ef9a492f2c624fd45ddde6135ec42
    bytes32 private constant ADMIN = keccak256(abi.encodePacked("ADMIN"));
    // 0x2db9fd3d099848027c2383d0a083396f6c41510d7acfd92adc99b6cffcf31e96
    bytes32 private constant USER = keccak256(abi.encodePacked("USER"));

    mapping( bytes32 => mapping ( address => bool)) public roles;

    modifier onlyRole(bytes32 _role) {
        require(roles[_role][msg.sender], "Not authorized");
        _;
    }

    constructor () {
        _grantAccess(ADMIN, msg.sender);
    }

    function _grantAccess(bytes32 _role, address _account) internal {
        roles[_role][_account] = true;
        emit GrantAccess(_role, _account);
    }

    function grantAccess(bytes32 _role, address _account) external onlyRole(ADMIN) {
        _grantAccess(_role, _account);
    }

    function revokeAccess(bytes32 _role, address _account) external onlyRole(ADMIN) {
        roles[_role][_account] = false;
        emit RevokeAccess(_role, _account);
    }

}