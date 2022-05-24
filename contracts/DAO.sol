// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.12;

import "./CommonDao.sol";

contract DAO is ICommonDAO {
    error SelectorNotAllowed();
    error InvalidCall();
    error InvalidProposalId();
    error UserTokensLocked();
    error AlreadyVoted();

    /**
     * @dev Proposal's ID.
     */
    uint96 private _proposalId;

    /**
     * @dev Address of the voting token.
     */
    address private _asset;

    /**
     * @dev Percent of the minimal allowed quorum.
     */
    uint128 private _minimumQuorum;

    /**
     * @dev Proposal's duration.
     */
    uint128 private _debatingDuration;

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
     * @dev Checks if proposal is exist.
     *
     * @param id Proposal id you want to check
     */
    modifier isValidID(uint256 id) {
        if(_proposals[id].end == 0) {
            revert InvalidProposalId();
        }

        _;
    }

    /**
     * @dev Sets {_asset}, {minimumQuorum} and {debatingDuration}
     */
    constructor(
        address asset_,
        uint128 minimumQuorum_,
        uint48 debatingDuration_
    ) {
        _asset = asset_;
        _minimumQuorum = minimumQuorum_ * uint128(IERC20(_asset).totalSupply()) / 100;
        _debatingDuration = debatingDuration_;
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
    function minimumQuorum() external view returns(uint128) {
        return _minimumQuorum;
    }

    /**
     * @dev Returns debating duration for the proposals.
     */
    function debatingDuration() external view returns(uint128) {
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

    function deposit(uint128 amount) external {
        User storage user = _users[msg.sender];
        if(user.locked){
            revert UserTokensLocked();
        }

        _deposit(msg.sender, amount);
        user.amount += amount;
    }

    function withdraw() external {
        User storage user = _users[msg.sender];
        if(user.locked){
            revert UserTokensLocked();
        }

        uint128 amount = user.amount;
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
            revert SelectorNotAllowed();
        }

        Proposal storage proposal = _proposals[_proposalId];
        proposal.recipient = recipient;
        proposal.description = description;
        proposal.callData = callData;
        proposal.end = uint96(block.timestamp + _debatingDuration);
        proposal.status = Status.ADDED;

        emit addedProposal(_proposalId, callData);

        _proposalId++;
    }

    /**
     * @dev
     */
    function vote(
        uint128 id,
        bool support
    ) 
        external
        isValidID(id) 
    {
        Proposal storage proposal = _proposals[id];
        User storage user = _users[msg.sender];

        if(alreadyVoted(user.proposalIds, id)){
            revert AlreadyVoted();
        }
        if(support) { 
            proposal.votesFor+= user.amount; 
        }
        else { 
            proposal.votesAgainst++; 
        }
        
        user.locked = true;
        user.proposalIds.push(id);
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
    function setMinimalQuorum(uint128 newQuorum) external {
        _minimumQuorum = newQuorum * uint128(IERC20(_asset).totalSupply());
    }

    /**
     * @dev Sets the debating period for proposals.
     *
     * @param newPeriod New debating period you want to set.
     * NOTE: Only admin can call this funciton.
     */
    function setDebatingPeriod(uint48 newPeriod) external {
        _debatingDuration = newPeriod;
    }

    /**
     * @dev Adds the new selector to mapping of the allowed selectors.
     */
    function addSupportedSelector(bytes4 selector) external {
        _selectors[selector] = true;
    }

    function _finishProposal(uint256 id) 
        internal 
    {
        Proposal storage proposal = _proposals[id];

        if(!_canBeFinished(proposal)){
            revert CannotBeFinished();
        }

        Result result = Result.DENIED;
        proposal.status = Status.FINISHED;

        if(proposal.votesFor > proposal.votesAgainst) {
            (bool _result,) = proposal.recipient.call(proposal.callData);
            if(!_result) {
                revert InvalidCall();
            }

            result = Result.ACCEPTED;
        }

        emit finishedProposal(id, result);
    }

    function _canBeFinished(
        Proposal storage p
    ) 
        internal
        view
        returns(bool)
    {
        return (p.votesFor + p.votesAgainst >= _minimumQuorum && block.timestamp >= p.end);
    }

    function _deposit(address sender, uint256 amount) internal {
        IERC20(_asset).transferFrom(sender, address(this), amount);
    }

    function _withdraw(address recipient, uint256 amount) internal {
        IERC20(_asset).transfer(recipient, amount);
    }

    function alreadyVoted(uint128[] memory proposalIds, uint256 id) internal pure returns(bool) {
        uint8 low = 0;
        uint8 high = uint8(proposalIds.length);

        while(low <= high) {
            uint8 middle = (high + low) / 2;

            if(id == proposalIds[middle]) return true;
            else if(id < proposalIds[middle]) high = middle -1;
            else low = middle + 1;
        }

        return false;
    }
}