// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.12;

import "./CommonDao.sol";
import "hardhat/console.sol";

/**
 * @title Decentralized autonomous organization
 * @author Galas' Danil
 * @notice This is a simple realization of DAO with delegation mechanism
 */
contract DAO is ICommonDAO {
    /**
     * @dev Address of the voting token.
     */
    address private _asset;

    /**
     * @dev Proposal's ID.
     */
    uint256 private _proposalId;

    /**
     * @dev Percent of the minimal allowed quorum.
     */
    uint256 private _minimumQuorum;

    /**
     * @dev Proposal's duration.
     */
    uint256 private _debatingDuration;

    /**
     * @dev Proposal information by ID.
     */
    mapping(uint256 => Proposal) private _proposals;

     /**
     * @dev User information by address.
     */
    mapping(address => User) private _users;

    /**
     * @dev Support of the particular selector.
     */
    mapping(bytes4 => bool) private _selectors;

    /**
     * @dev Delegated amount by delagator and proposal ID.
     */
    mapping(address => mapping(uint256 => DelegatedInfo)) private _delegatedAmount;

    /**
     * @dev Information about voting accounts for a proposal.
     */
    mapping(address => mapping(uint256 => VotingStatus)) private _voted;

    /**
     * @dev Checks if proposal is exist.
     * @param id Proposal id you want to check
     */
    modifier validateId(uint256 id) {
        if(_proposals[id].end == 0) {
            revert InvalidProposalId();
        }

        _;
    }

    /**
     * @dev Check is stage is equal to provided.
     *
     * @param status Required stage
     * @param id Proposal ID
     */
    modifier atStage(ProposalStatus status, uint256 id) {
        if(_proposals[id].status != status) {
            revert InvalidStage();
        }

        _;
    }

    /**
     * @dev Provide guard from multiple voting or delegating
     */
    modifier isVoted(uint256 id) {
        if(_voted[msg.sender][id] != VotingStatus.UNDEFINED) {
            revert AlreadyVoted();
        }

        _;
    }

    /**
     * @dev Sets {_asset}, {minimumQuorum} and {debatingDuration},
     * Adds 3 selectors - for setting {minimumQuorum} and {debatingDuration}
     * and for adding new selectors
     */
    constructor(
        address asset_,
        uint256 minimumQuorum_,
        uint256 debatingDuration_
    ) {
        _asset = asset_;
        _minimumQuorum = minimumQuorum_ * IERC20(_asset).totalSupply() / 100;
        _debatingDuration = debatingDuration_;

        _selectors[
            bytes4(keccak256("setMinimalQuorum(uint256)"))
        ] = true;
        _selectors[
            bytes4(keccak256("setDebatingPeriod(uint256)"))
        ] = true;
        _selectors[
            bytes4(keccak256("addSupportedSelector(bytes4)"))
        ] = true;
    }

    /**
     * @dev Delegate votes to `delegatee` by proposal ID.
     */
    function delegate(uint256 id, address delegatee)
        external 
        validateId(id)
        isVoted(id)
        atStage(ProposalStatus.ADDED, id)
    {  
        User storage user = _users[msg.sender];
        Proposal storage proposal = _proposals[id];

        if(proposal.end <= block.timestamp) {
            revert InvalidDelegate();
        }
        if(_voted[delegatee][id] != VotingStatus.UNDEFINED) {
            revert AlreadyVoted();
        }

        if(user.lockedTill < proposal.end) {
            user.lockedTill = proposal.end;
        }

        _delegatedAmount[delegatee][id].amount += user.amount;
        _voted[msg.sender][id] = VotingStatus.DELEGATED;

        emit DelegatedVotes(msg.sender, delegatee, id, user.amount);
    }

    /**
     * @dev Adds the proposal for the voting.
     */
    function addProposal(
        address recipient,
        string memory description,
        bytes memory callData
    )
        external
    {
        if(!_selectors[bytes4(callData)]) {
            revert InvalidSelector();
        }

        Proposal storage proposal = _proposals[_proposalId];
        proposal.recipient = recipient;
        proposal.description = description;
        proposal.callData = callData;
        proposal.end = uint96(block.timestamp + _debatingDuration);
        proposal.status = ProposalStatus.ADDED;

        emit AddedProposal(_proposalId, callData);

        _proposalId++;
    }

    /**
     * @dev
     */
    function vote(
        uint256 id,
        bool support
    ) 
        external
        validateId(id)
        isVoted(id)
        atStage(ProposalStatus.ADDED, id)
    {
        Proposal storage proposal = _proposals[id];
        User storage user = _users[msg.sender];
        DelegatedInfo storage info = _delegatedAmount[msg.sender][id];

        if(proposal.end <= block.timestamp) {
            revert InvalidTime();
        }

        if(support) { 
            proposal.votesFor += user.amount + info.amount; 
        }
        else { 
            proposal.votesAgainst += user.amount + info.amount; 
        }

        if(user.lockedTill < proposal.end) {
            user.lockedTill = proposal.end;
        }

        _voted[msg.sender][id] = VotingStatus.VOTED;

        emit Voted(msg.sender, id, support);
    }

    function finishProposal(
        uint256 id
    )
        external
        validateId(id)
        atStage(ProposalStatus.ADDED, id) 
    {
        Proposal storage proposal = _proposals[id];

        if (block.timestamp < proposal.end) {
            revert InvalidTime();
        }
        else {
            if (proposal.votesFor + proposal.votesAgainst < _minimumQuorum) {
                revert InvalidQuorum();
            } else {
                bool isAccepted; 
                bool isSuccessfulCall;

                if(proposal.votesFor > proposal.votesAgainst) {
                    isAccepted = true;

                    (bool _result,) = proposal.recipient.call(proposal.callData);
                    if(_result) {
                        isSuccessfulCall = true;
                    }
                }

                proposal.status = ProposalStatus.FINISHED;
                emit FinishedProposal(id, isAccepted, isSuccessfulCall);
            }    
        }
        
    }

    function deposit(uint256 amount) external {
        _deposit(msg.sender, amount);

        User storage user = _users[msg.sender];
        user.amount += amount;

        emit Deposited(msg.sender, amount);
    }

    function withdraw() external {
        User storage user = _users[msg.sender];
        if(block.timestamp < user.lockedTill){
            revert UserTokensLocked();
        }

        uint256 amount = user.amount;
        user.amount = 0;
        _withdraw(msg.sender, amount);

        emit Withdrawed(msg.sender, amount);
    }

    /**
     * @dev Sets the minimal quorum.
     *
     * @param newQuorum New minimal quorum you want to set.
     * NOTE: Only admin can call this funciton.
     */
    function setMinimalQuorum(uint256 newQuorum) external {
        _minimumQuorum = newQuorum * IERC20(_asset).totalSupply() / 100;
    }

    /**
     * @dev Sets the debating period for proposals.
     *
     * @param newPeriod New debating period you want to set.
     * NOTE: Only admin can call this funciton.
     */
    function setDebatingPeriod(uint256 newPeriod) external {
        _debatingDuration = newPeriod;
    }

    /**
     * @dev Adds the new selector to mapping of the allowed selectors.
     */
    function addSupportedSelector(bytes4 selector) external {
        _selectors[selector] = true;
    }

    /**
     * @dev Returns the address of the voting token.
     */
    function asset() external view returns(address) {
        return _asset;
    }

    /**
     * @dev Returns minimal quorum for the proposals.
     */
    function minimumQuorum() external view returns(uint256) {
        return _minimumQuorum;
    }

    /**
     * @dev Returns debating duration for the proposals.
     */
    function debatingDuration() external view returns(uint256) {
        return _debatingDuration;
    }

    /**
     * @dev Returns the amount of the proposals.
     */
    function proposalId() external view returns(uint256) {
        return _proposalId;
    }

    /**
     * @dev Returns true of selector is supported by DAO.
     */
    function isSupportedSelector(bytes4 selector) external view returns(bool) {
        return _selectors[selector];
    }

    function userInfo() external view returns(User memory) {
        return _users[msg.sender];
    }

    function _deposit(address sender, uint256 amount) internal {
        IERC20(_asset).transferFrom(sender, address(this), amount);
    }

    function _withdraw(address recipient, uint256 amount) internal {
        IERC20(_asset).transfer(recipient, amount);
    }
}