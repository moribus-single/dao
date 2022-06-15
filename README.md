# DAO
Decentralized autonomous organization with delegation mechanism.</br> Documentation of the project contains in `doc` folder (generated by dodoc)

## Installation
```bash
$ npm use
```

```bash
$ npm install
```

## Development

### Running tests
Create your tests in test folder. To set typed test, describe types in `test.config.d.ts`. Then, use it with Mocha.Context (this)

Run tests with command:
```bash
$ npx hardhat test TEST_PATH
```

Run tests and calculate gasPrice with command:
```bash
$ REPORT_GAS=true npx hardhat test
```

### Deploy
Run deploy in hardhat network
```bash
$ npx hardhat deploy
```

Run deploy in ropsten network
```bash
$ npm run deploy:ropsten 
```

Run deploy in ropsten network for new contract
```bash
$ npm run deploy:ropsten:new
```
### Verification contract  

Run verify in ropsten network
```bash
$ npm run verify:ropsten
```

