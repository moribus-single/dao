// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.12;

import "@openzeppelin/contracts/interfaces/IERC20.sol";

interface ICommonDAO {
    error InvalidQuorum();
    error InvalidTime();
    error InvalidSelector();
    error InvalidProposalId();
    error UserTokensLocked();
    error AlreadyVoted();
    error InvalidStage();

    enum ProposalStatus {
        UNDEFINED,
        ADDED,
        FINISHED
    }

    enum VotingStatus {
        UNDEFINED,
        VOTED,
        DELEGATED
    }

    struct Proposal {
        address recipient;
        uint256 end;
        uint256 votesFor;
        uint256 votesAgainst;
        bytes callData;
        string description;
        ProposalStatus status;
    }

    struct User {
        uint256 amount;
        uint256 lockedTill;
    }

    /**
     * @dev Emits every time proposal is added.
     *
     * @param proposalId Id of the proposal.
     * @param callData Call data for make a call to another contract.
     */
    event AddedProposal(uint256 indexed proposalId, bytes callData);

    /**
     * @dev Emits when some user is voted
     *
     * @param user Address of the user, which want to vote.
     * @param proposalId ID of the proposal, user want to vote
     * @param support Boolean value, represents the user opinion
     */
    event Voted(address indexed user, uint256 indexed proposalId, bool support);

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
     * @param delegator Address of the user, who delegates votes.
     * @param delegatee Address of the user, which is delegated to.
     * @param proposalId ID of the proposal, in which delegator delegates votes
     */
    event DelegatedVotes(address indexed delegator, address indexed delegatee, uint256 indexed proposalId, uint256 amount);

    /**
     * @dev Emits when some user deposits any amount of tokens.
     *
     * @param user Address of the user, who deposits
     * @param amount Amount of tokens to deposit
     */
    event Deposited(address indexed user, uint256 amount);

    /**
     * @dev Emits when some user withdraws any amount of tokens.
     *
     * @param user Address of the user, who withdraws
     * @param amount Amount of tokens to withdraw
     */
    event Withdrawed(address indexed user, uint256 amount);
}
