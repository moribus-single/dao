// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.12;

import "./CommonDao.sol";

contract DAO is CommonDAO {
    error SelectorNotAllowed();
    error InvalidCall();
    error InvalidProposalId();

    /**
     * @dev Proposal's ID.
     */
    uint256 private _proposalId;

    /**
     * @dev Proposal information by ID.
     */
    mapping(uint256 => Proposal) private _proposals;

     /**
     * @dev Amount of the voting token deposited user.
     */
    mapping(address => uint256) private _deposits;

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
        if(_proposals[id].start == 0) {
            revert InvalidProposalId();
        }

        _;
    }

    /**
     * @dev See {CommonDAO-constructor}
     */
    constructor(
        address asset_,
        uint8 minimumQuorum_,
        uint48 debatingDuration_
    ) CommonDAO(
        asset_,
        minimumQuorum_,
        debatingDuration_
    ) {}

    /**
     * @dev Returns the amount of the proposals.
     */
    function proposalId() external view returns(uint256) {
        return _proposalId;
    }

    /**
     * @dev Adds the new selector to mapping of the allowed selectors.
     */
    function addSupportedSelector(bytes4 selector) external onlyOwner {
        _selectors[selector] = true;
    }
    /**
     * @dev Returns true of selector is supported by DAO.
     */
    function isSupportedSelector(bytes4 selector) external view returns(bool) {
        return _selectors[selector];
    }

    function deposit(uint256 amount) external {
        _deposit(msg.sender, amount);
        _deposits[msg.sender] += amount;
    }

    function withdraw() external {
        uint256 amount = _deposits[msg.sender];
        _deposits[msg.sender] = 0;
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
        if(_selectors[bytes4(callData)]) {
            revert SelectorNotAllowed();
        }

        Proposal storage proposal = _proposals[_proposalId];
        proposal.recipient = recipient;
        proposal.description = description;
        proposal.callData = callData;
        proposal.start = uint96(block.timestamp);
        proposal.status = Status.ADDED;

        emit addedProposal(_proposalId, callData);

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
        if(support) { 
            proposal.votesFor++; 
        }
        else { 
            proposal.votesAgainst++; 
        }

        proposal.quorum += _deposits[msg.sender];
    }

    function finishProposal(
        uint256 id
    )
        external
        isValidID(id)
    {
        _finishProposal(id);

        Proposal storage proposal = _proposals[id];
        proposal.status = Status.FINISHED;
    }

    function _finishProposal(uint256 id) 
        internal 
    {
        if(!_canBeFinished(id)){
            revert CannotBeFinished();
        }

        Result result = Result.DENIED;

        Proposal storage proposal = _proposals[id];
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
        uint256 id
    ) 
        internal
        view
        returns(bool)
    {
        Proposal storage p= _proposals[id];
        return (p.quorum >= minimumQuorum && block.timestamp - p.start > debatingDuration);
    }
}