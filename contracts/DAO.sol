// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.12;

import "./CommonDao.sol";
import "hardhat/console.sol";

contract DAO is ICommonDAO {
    /**
     * @dev Proposal's ID.
     */
    uint256 private _proposalId;

    /**
     * @dev Address of the voting token.
     */
    address private _asset;

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
     * @dev Delegatee by address and proposal ID.
     */
    mapping(address => mapping(uint256 => DelegateInfo)) private _delegatee;

    /**
     * @dev Delegated amount by delagator and proposal ID.
     */
    mapping(address => mapping(uint256 => DelegatedInfo)) private _delegatedAmount;

    /**
     * @dev Information about voting accounts for a proposal.
     */
    mapping(uint256 => mapping(address => bool)) private _voted;

    /**
     * @dev Checks if proposal is exist.
     * @param id Proposal id you want to check
     */
    modifier isValidID(uint256 id) {
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
    modifier atStage(Status status, uint256 id) {
        if(_proposals[id].status != status) {
            revert InvalidStage();
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
            bytes4(keccak256("setMinimalQuorum(uint128)"))
        ] = true;
        _selectors[
            bytes4(keccak256("setDebatingPeriod(uint128)"))
        ] = true;
        _selectors[
            bytes4(keccak256("addSupportedSelector(bytes4)"))
        ] = true;
    }

    function delegate(uint256 id, address delegatee) external isValidID(id) {
        DelegateInfo storage delegateInfo = _delegatee[msg.sender][id];
        if(delegateInfo.amount > 0 || _voted[id][msg.sender] || _voted[id][delegatee]) {
            revert InvalidDelegate();
        }
        
        User storage user = _users[msg.sender];
        Proposal storage proposal = _proposals[id];

        _updateLockTime(user, proposal);
        _delegatedAmount[delegatee][id].amount += user.amount;
        delegateInfo.delegatee = delegatee;
        delegateInfo.amount = user.amount;

        emit DelegatedVotes(msg.sender, delegatee, id, user.amount);
    }

    function deposit(uint256 amount) external {
        _deposit(msg.sender, amount);

        User storage user = _users[msg.sender];
        user.amount += amount;
    }

    function withdraw() external {
        User storage user = _users[msg.sender];
        if(block.timestamp < user.lockedTill){
            revert UserTokensLocked();
        }

        uint256 amount = user.amount;
        user.amount = 0;
        _withdraw(msg.sender, amount);
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
        proposal.status = Status.ADDED;

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
        isValidID(id) 
    {
        Proposal storage proposal = _proposals[id];
        User storage user = _users[msg.sender];

        _canVote(proposal, id);
        _vote(proposal, user, id, support);
        _updateLockTime(user, proposal);
    }

    function finishProposal(
        uint256 id
    )
        external
        isValidID(id)
    {
        _finishProposal(id);
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

    function user() external view returns(User memory) {
        return _users[msg.sender];
    }

    function _finishProposal(uint256 id) 
        internal 
    {
        Proposal storage proposal = _proposals[id];
        if(!_canBeFinished(proposal) || proposal.status != Status.ADDED){
            revert CannotBeFinished();
        }
        (bool isAccepted, bool isSuccessfulCall) = _execute(proposal);

        emit FinishedProposal(id, isAccepted, isSuccessfulCall);
    }

    function _execute(Proposal storage proposal) 
        internal 
        returns (bool isAccepted, bool isSuccessfulCall) 
    {
        proposal.status = Status.FINISHED;

        if(proposal.votesFor > proposal.votesAgainst) {
            isAccepted = true;

            (bool _result,) = proposal.recipient.call(proposal.callData);
            if(_result) {
                isSuccessfulCall = true;
            }
        }
    }

    function _vote(
        Proposal storage _proposal, 
        User storage _user, 
        uint256 _id, 
        bool _support
    ) internal {
        DelegatedInfo storage info = _delegatedAmount[msg.sender][_id];

        if(_support) { 
            _proposal.votesFor += _user.amount + info.amount; 
        }
        else { 
            _proposal.votesAgainst += _user.amount + info.amount; 
        }

        _voted[_id][msg.sender] = true;
    }

    function _updateLockTime(User storage _user, Proposal storage _proposal) internal {
        if(_user.lockedTill < _proposal.end) {
            _user.lockedTill = _proposal.end;
        }
    }

    function _canVote(Proposal memory _proposal, uint256 _id) internal view {
        if(_voted[_id][msg.sender] || _delegatee[msg.sender][_id].amount > 0 || _proposal.status != Status.ADDED){
            revert InvalidVote();
        }
    }

    function _canBeFinished(
        Proposal storage _proposal
    ) 
        internal
        view
        returns(bool)
    {
        return (_proposal.votesFor + _proposal.votesAgainst >= _minimumQuorum && block.timestamp >= _proposal.end);
    }

    function _deposit(address sender, uint256 amount) internal {
        IERC20(_asset).transferFrom(sender, address(this), amount);
    }

    function _withdraw(address recipient, uint256 amount) internal {
        IERC20(_asset).transfer(recipient, amount);
    }
}