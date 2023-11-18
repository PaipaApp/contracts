interface IFeeTokenRegistry {
    function approveTokens(address[] memory _tokens) external;

    function revokeTokens(address[] memory _tokens) external;
}
