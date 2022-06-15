# DAO

*Galas&#39; Danil*

> Decentralized autonomous organization

This is a simple realization of DAO with delegation mechanism



## Methods

### addProposal

```solidity
function addProposal(address recipient, string description, bytes callData) external nonpayable
```



*Adds the proposal for the voting. NOTE: Anyone can add new proposal*

#### Parameters

| Name | Type | Description |
|---|---|---|
| recipient | address | Address of the contract to call the function with call data |
| description | string | Short description of the proposal |
| callData | bytes | Call data for calling the function with call() |

### addSupportedSelector

```solidity
function addSupportedSelector(bytes4 selector) external nonpayable
```



*Adds the new selector to mapping of the allowed selectors.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| selector | bytes4 | undefined |

### asset

```solidity
function asset() external view returns (address)
```



*Returns the address of the voting token.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### debatingDuration

```solidity
function debatingDuration() external view returns (uint256)
```



*Returns debating duration for the proposals.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### delegate

```solidity
function delegate(uint256 id, address delegatee) external nonpayable
```



*Delegate votes to `delegatee` by proposal ID.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| id | uint256 | undefined |
| delegatee | address | undefined |

### deposit

```solidity
function deposit(uint256 amount) external nonpayable
```



*Deposits `amount` of tokens to the DAO*

#### Parameters

| Name | Type | Description |
|---|---|---|
| amount | uint256 | Amount of tokens to deposit |

### finishProposal

```solidity
function finishProposal(uint256 id) external nonpayable
```

Proposal could be finished after duration timeProposal considers successful if enough quorum is used for voting

*Finishes the particular proposal*

#### Parameters

| Name | Type | Description |
|---|---|---|
| id | uint256 | undefined |

### getVotingStatus

```solidity
function getVotingStatus(address user, uint256 id) external view returns (enum ICommonDAO.VotingStatus)
```



*Returns the voting status of the user*

#### Parameters

| Name | Type | Description |
|---|---|---|
| user | address | Address of the user |
| id | uint256 | Proposal ID |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | enum ICommonDAO.VotingStatus | undefined |

### isSupportedSelector

```solidity
function isSupportedSelector(bytes4 selector) external view returns (bool)
```



*Returns true of selector is supported by DAO.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| selector | bytes4 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### minimumQuorum

```solidity
function minimumQuorum() external view returns (uint256)
```



*Returns minimal quorum for the proposals.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### proposalId

```solidity
function proposalId() external view returns (uint256)
```



*Returns the amount of the proposals.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### setDebatingPeriod

```solidity
function setDebatingPeriod(uint256 newPeriod) external nonpayable
```

Only admin can call this funciton.

*Sets the debating period for proposals.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| newPeriod | uint256 | New debating period you want to set. |

### setMinimalQuorum

```solidity
function setMinimalQuorum(uint256 newQuorum) external nonpayable
```

Only admin can call this funciton.

*Sets the minimal quorum.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| newQuorum | uint256 | New minimal quorum you want to set. |

### userInfo

```solidity
function userInfo() external view returns (struct ICommonDAO.User)
```



*Returns information about sender*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | ICommonDAO.User | undefined |

### vote

```solidity
function vote(uint256 id, bool support) external nonpayable
```



*Votes for the particular proposal NOTE: Before voting user should deposit some tokens into DAO*

#### Parameters

| Name | Type | Description |
|---|---|---|
| id | uint256 | Proposal ID you want to vote for |
| support | bool | Represents your support of this proposal |

### withdraw

```solidity
function withdraw() external nonpayable
```

Tokens could be withdrawn only after the longer proposal duration user votes for  

*Withdraws all the tokens from DAO*




## Events

### AddedProposal

```solidity
event AddedProposal(uint256 indexed proposalId, bytes callData)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| proposalId `indexed` | uint256 | undefined |
| callData  | bytes | undefined |

### DelegatedVotes

```solidity
event DelegatedVotes(address indexed delegator, address indexed delegatee, uint256 indexed proposalId, uint256 amount)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| delegator `indexed` | address | undefined |
| delegatee `indexed` | address | undefined |
| proposalId `indexed` | uint256 | undefined |
| amount  | uint256 | undefined |

### Deposited

```solidity
event Deposited(address indexed user, uint256 amount)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| user `indexed` | address | undefined |
| amount  | uint256 | undefined |

### FinishedProposal

```solidity
event FinishedProposal(uint256 indexed proposalId, bool isAccepted, bool isSuccessfulCall)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| proposalId `indexed` | uint256 | undefined |
| isAccepted  | bool | undefined |
| isSuccessfulCall  | bool | undefined |

### Voted

```solidity
event Voted(address indexed user, uint256 indexed proposalId, bool support)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| user `indexed` | address | undefined |
| proposalId `indexed` | uint256 | undefined |
| support  | bool | undefined |

### Withdrawed

```solidity
event Withdrawed(address indexed user, uint256 amount)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| user `indexed` | address | undefined |
| amount  | uint256 | undefined |



## Errors

### AlreadyVoted

```solidity
error AlreadyVoted()
```






### InvalidDelegate

```solidity
error InvalidDelegate()
```






### InvalidProposalId

```solidity
error InvalidProposalId()
```






### InvalidQuorum

```solidity
error InvalidQuorum()
```






### InvalidSelector

```solidity
error InvalidSelector()
```






### InvalidStage

```solidity
error InvalidStage()
```






### InvalidTime

```solidity
error InvalidTime()
```






### UserTokensLocked

```solidity
error UserTokensLocked()
```







