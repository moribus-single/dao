# ICommonDAO










## Events

### AddedProposal

```solidity
event AddedProposal(uint256 indexed proposalId, bytes callData)
```



*Emits every time proposal is added.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| proposalId `indexed` | uint256 | Id of the proposal. |
| callData  | bytes | Call data for make a call to another contract. |

### DelegatedVotes

```solidity
event DelegatedVotes(address indexed delegator, address indexed delegatee, uint256 indexed proposalId, uint256 amount)
```



*Emits when some user delegated votes.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| delegator `indexed` | address | Address of the user, who delegates votes. |
| delegatee `indexed` | address | Address of the user, which is delegated to. |
| proposalId `indexed` | uint256 | ID of the proposal, in which delegator delegates votes |
| amount  | uint256 | undefined |

### Deposited

```solidity
event Deposited(address indexed user, uint256 amount)
```



*Emits when some user deposits any amount of tokens.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| user `indexed` | address | Address of the user, who deposits |
| amount  | uint256 | Amount of tokens to deposit |

### FinishedProposal

```solidity
event FinishedProposal(uint256 indexed proposalId, bool isAccepted, bool isSuccessfulCall)
```



*Emits every time proposal is finished.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| proposalId `indexed` | uint256 | Id of the proposal. |
| isAccepted  | bool | Result of the proposal. |
| isSuccessfulCall  | bool | Result of the call. |

### Voted

```solidity
event Voted(address indexed user, uint256 indexed proposalId, bool support)
```



*Emits when some user is voted*

#### Parameters

| Name | Type | Description |
|---|---|---|
| user `indexed` | address | Address of the user, which want to vote. |
| proposalId `indexed` | uint256 | ID of the proposal, user want to vote |
| support  | bool | Boolean value, represents the user opinion |

### Withdrawed

```solidity
event Withdrawed(address indexed user, uint256 amount)
```



*Emits when some user withdraws any amount of tokens.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| user `indexed` | address | Address of the user, who withdraws |
| amount  | uint256 | Amount of tokens to withdraw |



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







