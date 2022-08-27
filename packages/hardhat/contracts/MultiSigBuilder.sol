// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;
import "./MultiSigWallet.sol";

contract MultiSigBuilder {
    MultiSigWallet[] public multiSigs;
    mapping(address => bool) public walletExists;

    //events
    event MultiSigWalletCreated(
        uint256 indexed contractId,
        address indexed walletAddress,
        address creator,
        address[] owners,
        uint256 numSignatureRequired
    );
    event WalletOwners(
        address indexed walletAddress,
        address[] owners,
        uint256 indexed numSignatureRequired
    );

    function buildMultiSigWallet(
        uint256 _chainId,
        address[] memory _owners,
        uint256 _numSignaturesRequired
    ) public payable {
        uint256 walletId = multiSigs.length;
        MultiSigWallet newWallet = new MultiSigWallet{value: msg.value}(
            _chainId,
            _owners,
            _numSignaturesRequired,
            payable(address(this))
        );
        address walletAddress = address(newWallet);
        require(!walletExists[walletAddress], "This wallet already exist");

        multiSigs.push(newWallet);
        walletExists[walletAddress] = true;

        emit MultiSigWalletCreated(
            walletId,
            walletAddress,
            msg.sender,
            _owners,
            _numSignaturesRequired
        );
        emit WalletOwners(walletAddress, _owners, _numSignaturesRequired);
    }

    function numberOfMultiSigsWallet() public view returns (uint256) {
        return multiSigs.length;
    }

    function getMultiSigWallet(uint256 _index)
        public
        view
        returns (
            address walletAddress,
            uint256 numSignatureRequired,
            uint256 balance
        )
    {
        MultiSigWallet wallet = multiSigs[_index];
        walletAddress = address(wallet);
        numSignatureRequired = wallet.numSignaturesRequired();
        balance = address(wallet).balance;
    }

    function emitOwners(
        address _contractAddress,
        address[] memory _owners,
        uint256 _numSignaturesRequired
    ) external {
        require(
            walletExists[msg.sender],
            "caller must be created by the MultiSigBuilder"
        );
        emit WalletOwners(_contractAddress, _owners, _numSignaturesRequired);
    }

    receive() external payable {}

    fallback() external payable {}
}
