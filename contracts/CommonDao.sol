// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.12;

import "@openzeppelin/contracts/interfaces/IERC20.sol";

interface ICommonDAO {
    error InvalidSelector();
    error InvalidCall();
    error InvalidProposalId();
    error UserTokensLocked();
    error InvalidVote();
    error InvalidDelegate();
    error InvalidUndelegate();
    
    enum Result {
        UNDEFINED,
        ACCEPTED,
        DENIED
    }

    enum Status {
        UNDEFINED,
        ADDED,
        FINISHED
    }

    struct Proposal {
        address recipient;
        uint96 end;
        uint128 votesFor;
        uint128 votesAgainst;
        bytes callData;
        string description;
        Status status;
    }

    struct User {
        uint128 amount;
        uint128[] proposalIds;
        uint96 lockedTill;
    }

    struct DelegateInfo {
        uint96 proposalId;
        address delegatee;
        uint128 amount;
    }

    struct DelegatedInfo {
        uint128 amount;
        bool voted;
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
