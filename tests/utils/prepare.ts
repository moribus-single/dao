import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers"
import { ethers } from "hardhat"

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
        "Money Token", 
        "MNY"
    );
    await token.deployed();
    thisObject.token = token;

    const daoFactory = await ethers.getContractFactory("DAO");
    const dao = await daoFactory.deploy(
        token.address,
        40,
        60*60*24*3
    )
    await dao.deployed();
    thisObject.dao = dao;
}
