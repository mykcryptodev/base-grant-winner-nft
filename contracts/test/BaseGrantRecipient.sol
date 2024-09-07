import {BaseGrantRecipient} from "../src/BaseGrantRecipient.sol";
import {Test} from "forge-std/Test.sol";

contract BaseGrantRecipientTest is Test {
    BaseGrantRecipient public baseGrantRecipient;
    address public owner;
    address public nonOwner;

    function setUp() public {
        owner = address(this);
        nonOwner = makeAddr("non-owner");
        baseGrantRecipient = new BaseGrantRecipient("Base Grant Recipient", "BASEGRANT", "ipfs://QmRijCow78NJUpnHUZtbrfEtqitBKXmGqX1j9w2Qdjj97n");
    }

    function testOwner() public {
        assertEq(address(baseGrantRecipient.owner()), address(this));
    }

    function testSetOwner() public {
        baseGrantRecipient.transferOwnership(nonOwner);
        assertEq(address(baseGrantRecipient.owner()), nonOwner);
    }

    // owner can mint to other addresses
    function testMintBatch() public {
        address[] memory to = new address[](2);
        to[0] = makeAddr("to0");
        to[1] = makeAddr("to1");
        baseGrantRecipient.mintBatch(to);
        assertEq(baseGrantRecipient.ownerOf(0), to[0]);
        assertEq(baseGrantRecipient.ownerOf(1), to[1]);
    }

    // non owner cannot mint
    function testMintBatchNonOwner() public {
        address[] memory to = new address[](1);
        to[0] = makeAddr("to0");
        vm.prank(nonOwner);
        vm.expectRevert();
        baseGrantRecipient.mintBatch(to);
    }

    // holders cannot transfer the token
    function testTransfer() public {
        address nftHolder = makeAddr("nftHolder");
        address transferRecipient = makeAddr("transferRecipient");

        // mint nft to holder
        address[] memory to = new address[](1);
        to[0] = nftHolder;
        baseGrantRecipient.mintBatch(to);

        vm.prank(nftHolder);
        vm.expectRevert();
        // simulate the transfer
        baseGrantRecipient.transferFrom(nftHolder, transferRecipient, 0);
    }

    // holders can burn the token
    function testBurn() public {
        address nftHolder = makeAddr("nftHolder");

        // mint nft to holder
        address[] memory to = new address[](1);
        to[0] = nftHolder;
        baseGrantRecipient.mintBatch(to);

        vm.prank(nftHolder);
        baseGrantRecipient.burn(0);

        (bool success, bytes memory data) = address(baseGrantRecipient).staticcall(abi.encodeWithSignature("ownerOf(uint256)", 0));
        assertEq(success, false);
    }

    // owner can set the token URI
    function testSetTokenURI() public {
      // mint one nft
      address[] memory to = new address[](1);
      to[0] = makeAddr("to0");
      baseGrantRecipient.mintBatch(to);
      string memory newTokenURI = "https://example.com/new";
      baseGrantRecipient.setTokenURI(newTokenURI);
      assertEq(baseGrantRecipient.tokenURI(0), newTokenURI);
    }
}
