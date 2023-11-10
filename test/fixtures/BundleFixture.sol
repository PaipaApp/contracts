import {TransactionsFixture} from "./TransactionsFixture.sol";
import {IBundler} from "../../src/interfaces/IBundler.sol";
import {TransactionType, TransactionName} from "./TransactionsFixture.sol";

contract BundleFixture is TransactionsFixture {
    IBundler.Transaction[] public staticBundle;
    bool[][] public staticBundleArgTypes;

    // @dev It isn't possible to have a fully dynamic bundle, since the first tx
    // always needs to be static
    IBundler.Transaction[] public mixedBundle;
    bool[][] public mixedBundleArgTypes;

    IBundler.Transaction[] public staticStakeBundle;
    bool[][] public staticStakeArgTypes;

    IBundler.Transaction[] public dynamicStakeBundle;
    bool[][] public dynamicStakeArgTypes;

    function setUp() public virtual override {
        super.setUp();

        _createDefaultStaticBundle();
        _createDefaultMixedBundle();
        _createStaticStakeBundle();
        _createDynamicStakeBundle();
    }

    function _createDefaultStaticBundle() internal {
        staticBundle.push(transactions[TransactionType.STATIC][TransactionName.WITHDRAW].tx);

        staticBundleArgTypes = new bool[][](1);
        staticBundleArgTypes[0] = transactions[TransactionType.STATIC][TransactionName.WITHDRAW].txArgTypes;
    }

    function _createDefaultMixedBundle() internal {
        mixedBundle.push(transactions[TransactionType.STATIC][TransactionName.BALANCE_OF].tx);
        mixedBundle.push(transactions[TransactionType.DYNAMIC][TransactionName.WITHDRAW].tx);

        mixedBundleArgTypes = new bool[][](2);
        mixedBundleArgTypes[0] = transactions[TransactionType.STATIC][TransactionName.BALANCE_OF].txArgTypes;
        mixedBundleArgTypes[1] = transactions[TransactionType.DYNAMIC][TransactionName.WITHDRAW].txArgTypes;
    }

    function _createStaticStakeBundle() internal {
        staticStakeBundle.push(transactions[TransactionType.STATIC][TransactionName.APPROVE].tx);
        staticStakeBundle.push(transactions[TransactionType.STATIC][TransactionName.DEPOSIT].tx);

        staticStakeArgTypes = new bool[][](2);
        staticStakeArgTypes[0] = transactions[TransactionType.STATIC][TransactionName.APPROVE].txArgTypes;
        staticStakeArgTypes[1] = transactions[TransactionType.STATIC][TransactionName.DEPOSIT].txArgTypes;
    }

    function _createDynamicStakeBundle() internal {
        // @dev Set the approve arg to mockStake contract and make it static arg
        IBundler.Transaction memory approve = transactions[TransactionType.DYNAMIC][TransactionName.APPROVE].tx;
        approve.args[0] = bytes(abi.encode(address(mockStake)));
        bool[] memory approveArgTypes = transactions[TransactionType.DYNAMIC][TransactionName.APPROVE].txArgTypes;
        approveArgTypes[0] = false;

        // @dev Set the approve arg to mockStake contract and make it static arg
        IBundler.Transaction memory balanceOf = transactions[TransactionType.STATIC][TransactionName.BALANCE_OF].tx;
        balanceOf.args[0] = bytes(abi.encode(address(bundler)));

        dynamicStakeBundle.push(balanceOf);
        dynamicStakeBundle.push(approve);
        dynamicStakeBundle.push(balanceOf);
        dynamicStakeBundle.push(transactions[TransactionType.DYNAMIC][TransactionName.DEPOSIT].tx);

        dynamicStakeArgTypes = new bool[][](4);
        dynamicStakeArgTypes[0] = transactions[TransactionType.STATIC][TransactionName.BALANCE_OF].txArgTypes;
        dynamicStakeArgTypes[1] = approveArgTypes;
        dynamicStakeArgTypes[2] = transactions[TransactionType.STATIC][TransactionName.BALANCE_OF].txArgTypes;
        dynamicStakeArgTypes[3] = transactions[TransactionType.DYNAMIC][TransactionName.DEPOSIT].txArgTypes;
    }
}
