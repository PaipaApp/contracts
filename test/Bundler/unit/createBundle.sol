import {BundleFixture} from "../../fixtures/BundleFixture.sol";
import {TransactionType, TransactionName} from "../../fixtures/TransactionsFixture.sol";

// Given the owner of the contract
//      When the owner creates a bundle
//      And the bundle is longer than MAX_BUNDLE_SIZE
//          Then the transaction reverts with MaxTransactionPerBundle
contract CreateBundleTestUnit is BundleFixture {
    function setUp() public override {
        super.setUp();
    }

    function test_CreateBundleWithMoreThanMaxTransactions() public {
        uint256[] memory transactionIds = new uint256[](bundler.MAX_BUNDLE_SIZE() + 1);
        for (uint256 i = 0; i < bundler.MAX_BUNDLE_SIZE() + 1; i++) {
            transactionIds[i] = transactions[TransactionType.STATIC][TransactionName.WITHDRAW].tx;
        }

        (bool success, bytes memory result) = address(bundler).call(abi.encodeWithSelector(bundler.createBundle.selector, transactionIds));
        assertEq(success, false);
        assertEq(result, abi.encodePacked("MaxTransactionPerBundle"));
    }
}

