// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.12;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface ICommonDAO {
    enum Result {
        UNDEFINED,
        ACCEPTED,
        DENIED
    }

    error CannotBeFinished();

    /**
     * @dev Emits every time proposal is added.
     *
     * @param proposalId Id of the proposal.
     * @param callData Call data for make a call to another contract.
     */
    event addedProposal(uint256 indexed proposalId, bytes callData);

    /**
     * @dev Emits every time proposal is finished.
     *
     * @param proposalId Id of the proposal.
     * @param result Result of the proposal.
     */
    event finishedProposal(uint256 indexed proposalId, Result result);
}


contract CommonDAO is ICommonDAO, Ownable {
    enum Status {
        UNDEFINED,
        ADDED,
        FINISHED
    }

    struct Proposal {
        address recipient;
        uint96 start;
        uint128 votesFor;
        uint128 votesAgainst;
        uint256 quorum;
        bytes callData;
        string description;
        Status status;
    }

    /**
     * @dev Address of the voting token.
     */
    address private _asset;

    /**
     * @dev Percent of the minimal allowed quorum.
     */
    uint256 public minimumQuorum;

    /**
     * @dev Proposal's duration.
     */
    uint48 public debatingDuration;

    /**
     * @dev Sets {_asset}, {minimumQuorum} and {debatingDuration}
     */
    constructor(
        address asset_,
        uint8 minimumQuorum_,
        uint48 debatingDuration_
    ) {
        _asset = asset_;
        minimumQuorum = minimumQuorum_ * IERC20(_asset).totalSupply();
        debatingDuration = debatingDuration_;
    }

    /**
     * @dev Returns the address of the voting token.
     */
    function asset() external view returns(address) {
        return _asset;
    }

    /**
     * @dev Sets the minimal quorum.
     *
     * @param newQuorum New minimal quorum you want to set.
     * NOTE: Only admin can call this funciton.
     */
    function setMinimalQuorum(uint8 newQuorum) external onlyOwner {
        minimumQuorum = newQuorum * IERC20(_asset).totalSupply();
    }

    /**
     * @dev Sets the debating period for proposals.
     *
     * @param newPeriod New debating period you want to set.
     * NOTE: Only admin can call this funciton.
     */
    function setDebatingPeriod(uint48 newPeriod) external onlyOwner {
        debatingDuration = newPeriod;
    }

    function _deposit(address sender, uint256 amount) internal {
        IERC20(_asset).transferFrom(sender, address(this), amount);
    }

    function _withdraw(address recipient, uint256 amount) internal {
        IERC20(_asset).transfer(recipient, amount);
    }
}
