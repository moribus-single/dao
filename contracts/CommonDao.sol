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
    error CannotBeFinished();
    error InvalidStage();

    enum Status {
        UNDEFINED,
        ADDED,
        FINISHED
    }

    struct Proposal {
        address recipient;
        uint256 end;
        uint256 votesFor;
        uint256 votesAgainst;
        bytes callData;
        string description;
        Status status;
    }

    struct User {
        uint256 amount;
        uint256 lockedTill;
    }

    struct DelegateInfo {
        address delegatee;
        uint256 amount;
    }

    struct DelegatedInfo {
        uint256 amount;
        bool voted;
    }

    /**
     * @dev Emits every time proposal is added.
     *
     * @param proposalId Id of the proposal.
     * @param callData Call data for make a call to another contract.
     */
    event AddedProposal(uint256 indexed proposalId, bytes callData);

    /**
     * @dev Emits every time proposal is finished.
     *
     * @param proposalId Id of the proposal.
     * @param isAccepted Result of the proposal.
     * @param isSuccessfulCall Result of the call.
     */
    event FinishedProposal(uint256 indexed proposalId, bool isAccepted, bool isSuccessfulCall);

    /**
     * @dev Emits when some user delegated votes.
     *
     * @param delegator Address of the user, who delegate votes.
     * @param delegatee Address of the user, which is delegated to.
     * @param proposalId ID of the proposal, in which delegator delegates votes
     */
    event DelegatedVotes(address indexed delegator, address indexed delegatee, uint256 indexed proposalId, uint256 amount);
}
