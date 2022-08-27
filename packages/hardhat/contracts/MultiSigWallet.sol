// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./MultiSigBuilder.sol";

contract MultiSigWallet {
    using ECDSA for bytes32;

    address[] public owners;
    uint256 public numSignaturesRequired;
    mapping(address => bool) public isOwner;
    uint256 public nonce;
    uint256 public chainId;

    MultiSigBuilder public multiSigBuilder;

    //events
    event ExecuteTransaction(
        address indexed owner,
        address indexed to,
        uint256 value,
        bytes data,
        uint256 nonce,
        bytes32 hash,
        bytes result
    );
    event OwnerChanged(address indexed owner, bool added);
    event Deposit(address indexed sender, uint256 amount, uint256 balance);

    modifier onlySelf() {
        require(msg.sender == address(this), "Only contract can execute");
        _;
    }

    constructor(
        uint256 _chainId,
        address[] memory _owners,
        uint256 _numSignaturesRequired,
        address payable _creatorAddress
    ) payable {
        require(_owners.length > 0, "Owners count can not be 0");
        require(
            _numSignaturesRequired > 0 &&
                _numSignaturesRequired <= _owners.length,
            "Invalid number for the required confirmation"
        );
        for (uint8 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(address(owner) != address(0), "Invalid address sent");
            require(!isOwner[owner], "Owner already exist");
            isOwner[owner] = true;
            owners.push(owner);
            emit OwnerChanged(owner, true);
        }
        chainId = _chainId;
        numSignaturesRequired = _numSignaturesRequired;
        multiSigBuilder = MultiSigBuilder(_creatorAddress);
    }

    // Add new Owner to this multisig wallet, with the new owner address and new number of signatures required when executing a transaction.
    function addOwner(address _address, uint256 _numSignaturesRequired)
        public
        onlySelf
    {
        require(address(_address) != address(0), "Invalid address sent");
        require(!isOwner[_address], "Owner already exist");
        require(
            _numSignaturesRequired > 0 &&
                _numSignaturesRequired <= owners.length + 1,
            "Invalid number for the required confirmation"
        );
        isOwner[_address] = true;
        owners.push(_address);
        numSignaturesRequired = _numSignaturesRequired;
        emit OwnerChanged(_address, true);
    }

    // Remove a owner
    function removeOwner(address _address, uint256 _numSignaturesRequired)
        public
        onlySelf
    {
        require(isOwner[_address], "This address is not owner");
        require(
            _numSignaturesRequired > 0 &&
                _numSignaturesRequired <= owners.length - 1,
            "Invalid number for the required confirmation"
        );
        for (uint8 i = 0; i < owners.length; i++) {
            address owner = owners[i];
            if (owner == _address) {
                owners[i] = owners[owners.length - 1];
                owners.pop();
                break;
            }
        }
        delete isOwner[_address];
        numSignaturesRequired = _numSignaturesRequired;
        emit OwnerChanged(_address, false);
        multiSigBuilder.emitOwners(
            address(this),
            owners,
            _numSignaturesRequired
        );
    }

    function updateSignaturesRequired(uint256 newSignaturesRequired)
        public
        onlySelf
    {
        require(
            newSignaturesRequired > 0 && newSignaturesRequired <= owners.length,
            "Given signature count is not valid"
        );
        numSignaturesRequired = newSignaturesRequired;
    }

    function getTransactionHash(
        uint256 _nonce,
        address _receiver,
        uint256 _value,
        bytes calldata _data
    ) public view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    address(this),
                    chainId,
                    _nonce,
                    _receiver,
                    _value,
                    _data
                )
            );
    }

    function recover(bytes32 _hash, bytes memory _signedSignature)
        public
        pure
        returns (address)
    {
        return _hash.toEthSignedMessageHash().recover(_signedSignature);
    }

    function executeTransaction(
        address payable _receiver,
        uint256 _value,
        bytes calldata _data,
        bytes[] calldata _signedSignatures
    ) public returns (bytes memory) {
        require(isOwner[msg.sender], "Only owners can execute");
        bytes32 _hash = getTransactionHash(nonce, _receiver, _value, _data);
        nonce++;

        uint256 validSignatures;
        address duplicateGuard;

        for (uint256 i = 0; i < _signedSignatures.length; i++) {
            bytes memory signature = _signedSignatures[i];
            address recoveredAddress = recover(_hash, signature);
            require(
                duplicateGuard < recoveredAddress,
                "duplicate or unordered signatures"
            );
            duplicateGuard = recoveredAddress;
            if (isOwner[recoveredAddress]) {
                validSignatures += 1;
            }
        }
        require(
            validSignatures >= numSignaturesRequired,
            "Not enough owners signed this trasnaction"
        );

        (bool success, bytes memory result) = _receiver.call{value: _value}(
            _data
        );
        require(success, "Transaction failed");
        emit ExecuteTransaction(
            msg.sender,
            _receiver,
            _value,
            _data,
            nonce - 1,
            _hash,
            result
        );
        return result;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    fallback() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }
}
