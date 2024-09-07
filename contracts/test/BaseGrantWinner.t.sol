import {BaseGrantWinner} from "../src/BaseGrantWinner.sol";
import {Test} from "forge-std/Test.sol";

contract BaseGrantWinnerTest is Test {
    BaseGrantWinner public baseGrantWinner;
    address public owner;
    address public nonOwner;

    function setUp() public {
        owner = address(this);
        nonOwner = makeAddr("non-owner");
        baseGrantWinner = new BaseGrantWinner("BaseGrantWinner", "BGW", "https://example.com/");
    }

    function testOwner() public {
        assertEq(address(baseGrantWinner.owner()), address(this));
    }

    function testSetOwner() public {
        baseGrantWinner.transferOwnership(nonOwner);
        assertEq(address(baseGrantWinner.owner()), nonOwner);
    }

    // owner can mint to other addresses
    function testMintBatch() public {
        address[] memory to = new address[](2);
        to[0] = makeAddr("to0");
        to[1] = makeAddr("to1");
        baseGrantWinner.mintBatch(to);
        assertEq(baseGrantWinner.ownerOf(0), to[0]);
        assertEq(baseGrantWinner.ownerOf(1), to[1]);
    }

    // non owner cannot mint
    function testMintBatchNonOwner() public {
        address[] memory to = new address[](1);
        to[0] = makeAddr("to0");
        vm.prank(nonOwner);
        vm.expectRevert();
        baseGrantWinner.mintBatch(to);
    }

    // holders cannot transfer the token
    function testTransfer() public {
        address nftHolder = makeAddr("nftHolder");
        address transferRecipient = makeAddr("transferRecipient");

        // mint nft to holder
        address[] memory to = new address[](1);
        to[0] = nftHolder;
        baseGrantWinner.mintBatch(to);

        vm.prank(nftHolder);
        vm.expectRevert();
        // simulate the transfer
        baseGrantWinner.transferFrom(nftHolder, transferRecipient, 0);
    }

    // holders can burn the token
    function testBurn() public {
        address nftHolder = makeAddr("nftHolder");

        // mint nft to holder
        address[] memory to = new address[](1);
        to[0] = nftHolder;
        baseGrantWinner.mintBatch(to);

        vm.prank(nftHolder);
        baseGrantWinner.burn(0);

        (bool success, bytes memory data) = address(baseGrantWinner).staticcall(abi.encodeWithSignature("ownerOf(uint256)", 0));
        assertEq(success, false);
    }

    // owner can set the token URI
    function testSetTokenURI() public {
      // mint one nft
      address[] memory to = new address[](1);
      to[0] = makeAddr("to0");
      baseGrantWinner.mintBatch(to);
      string memory newTokenURI = "https://example.com/new";
      baseGrantWinner.setTokenURI(newTokenURI);
      assertEq(baseGrantWinner.tokenURI(0), newTokenURI);
    }
}
