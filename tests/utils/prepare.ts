import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers"
import { ethers } from "hardhat"
import config from "../../config"

export async function prepareSigners(thisObject: Mocha.Context) {
    thisObject.signers = await ethers.getSigners()
    thisObject.owner = thisObject.signers[0]
    thisObject.user1 = thisObject.signers[1]
    thisObject.user2 = thisObject.signers[2]
    thisObject.user3 = thisObject.signers[3]
    thisObject.user4 = thisObject.signers[4]
    thisObject.user5 = thisObject.signers[5]
}

export async function deploy(thisObject: Mocha.Context, signer: SignerWithAddress) {
    const tokenFactory = await ethers.getContractFactory("Token");
    const token = await tokenFactory.connect(signer).deploy(
        config.token.name, 
        config.token.symbol
    );
    await token.deployed();
    await token.connect(signer).mint(
        signer.address, 
        ethers.utils.parseEther("1000000")
    );

    const daoFactory = await ethers.getContractFactory("DAO");
    const dao = await daoFactory.deploy(
        token.address,
        config.dao.minimumQuorum,
        config.dao.debatingDuration
    )
    await dao.deployed();
    
    thisObject.token = token;
    thisObject.dao = dao;
}
