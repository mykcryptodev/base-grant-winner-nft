// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title BaseGrantWinner
/// @notice This contract implements a soulbound NFT that cannot be transferred once minted
/// @dev Extends ERC721, ERC721Burnable, and Ownable
contract BaseGrantWinner is ERC721, ERC721Burnable, Ownable {
    uint256 private _tokenIdCounter;
    string private _tokenURI;

    // ERC-5192: Minimal Soulbound NFTs
    bytes4 private constant _INTERFACE_ID_ERC5192 = 0xb45a3c0e;

    /// @notice Emitted when a token is locked (minted)
    /// @param tokenId The ID of the locked token
    event Locked(uint256 tokenId);

    /// @notice Initializes the contract with a name, symbol, and initial token URI
    /// @param name The name of the NFT collection
    /// @param symbol The symbol of the NFT collection
    /// @param initialTokenURI The initial URI for token metadata
    constructor(string memory name, string memory symbol, string memory initialTokenURI) 
        ERC721(name, symbol)
        Ownable(msg.sender)
    {
        _tokenURI = initialTokenURI;
    }

    /// @notice Checks if the contract supports an interface
    /// @dev Overrides IERC165-supportsInterface
    /// @param interfaceId The interface identifier, as specified in ERC-165
    /// @return bool True if the contract supports the interface
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == _INTERFACE_ID_ERC5192 || super.supportsInterface(interfaceId);
    }

    /// @notice Checks if a token is locked (always returns true for soulbound tokens)
    /// @param tokenId The ID of the token to check
    /// @return bool Always returns true as tokens are always locked
    function locked(uint256 tokenId) external pure returns (bool) {
        return true;
    }

    /// @notice Mints multiple tokens to multiple addresses
    /// @dev Can only be called by the contract owner
    /// @param to An array of addresses to mint tokens to
    function mintBatch(address[] memory to) external onlyOwner {
        for (uint i = 0; i < to.length; i++) {
            uint256 tokenId = _tokenIdCounter;
            _tokenIdCounter++;
            _safeMint(to[i], tokenId);
            emit Locked(tokenId);
        }
    }

    /// @notice Burns a token
    /// @dev Can only be called by the token owner
    /// @param tokenId The ID of the token to burn
    function burn(uint256 tokenId) public override {
        require(ownerOf(tokenId) == _msgSender(), "BaseGrantWinner: caller is not token owner");
        super.burn(tokenId);
    }

    /// @notice Sets a new token URI for all tokens
    /// @dev Can only be called by the contract owner
    /// @param newTokenURI The new URI for token metadata
    function setTokenURI(string memory newTokenURI) external onlyOwner {
        _tokenURI = newTokenURI;
    }

    /// @notice Returns the URI for a given token
    /// @dev Overrides IERC721Metadata-tokenURI
    /// @param tokenId The ID of the token to get the URI for
    /// @return string The token URI
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "BaseGrantWinner: URI query for nonexistent token");
        return _tokenURI;
    }

    /// @notice Updates the ownership of a token
    /// @dev Overrides ERC721-_update to prevent transfers
    /// @param to The address to transfer to
    /// @param tokenId The ID of the token being transferred
    /// @param auth The address that authorized the transfer
    /// @return address The address of the previous owner
    function _update(address to, uint256 tokenId, address auth) internal override returns (address) {
        address from = _ownerOf(tokenId);
        require(from == address(0) || to == address(0), "BaseGrantWinner: token transfer is BLOCKED");
        return super._update(to, tokenId, auth);
    }

    /// @notice Checks if a token exists
    /// @param tokenId The ID of the token to check for existence
    /// @return bool True if the token exists, false otherwise
    function _exists(uint256 tokenId) internal view returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }
}