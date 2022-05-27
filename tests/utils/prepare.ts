import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers"
import { ethers } from "hardhat"
import config from "../../config"
import { DAO, Token} from "../../build/typechain"

export async function prepareSigners(thisObject: Mocha.Context) {
    thisObject.signers = await ethers.getSigners()
    thisObject.owner = thisObject.signers[0]
    thisObject.user1 = thisObject.signers[1]
    thisObject.user2 = thisObject.signers[2]
    thisObject.user3 = thisObject.signers[3]
    thisObject.user4 = thisObject.signers[4]
    thisObject.user5 = thisObject.signers[5]
    thisObject.user6 = thisObject.signers[6]
    thisObject.user7 = thisObject.signers[7]
}

export async function prepare(thisObject: Mocha.Context, signer: SignerWithAddress): Promise<[DAO, Token]> {
    const tokenFactory = await ethers.getContractFactory("Token");
    const token: Token = await tokenFactory.connect(signer).deploy(
        config.token.name, 
        config.token.symbol
    );
    await token.deployed();
    await token.connect(signer).mint(
        signer.address, 
        ethers.utils.parseEther("1000000")
    );
    await token.connect(signer).mint(
        thisObject.user1.address, 
        ethers.utils.parseEther("1000000")
    );
    await token.connect(signer).mint(
        thisObject.user2.address, 
        ethers.utils.parseEther("1000000")
    );
    await token.connect(signer).mint(
        thisObject.user3.address, 
        ethers.utils.parseEther("1000000")
    );
    await token.connect(signer).mint(
        thisObject.user4.address, 
        ethers.utils.parseEther("1000000")
    );
    await token.connect(signer).mint(
        thisObject.user5.address, 
        ethers.utils.parseEther("1000000")
    );
    await token.connect(signer).mint(
        thisObject.user6.address, 
        ethers.utils.parseEther("1000000")
    );
    await token.connect(signer).mint(
        thisObject.user7.address, 
        ethers.utils.parseEther("1000000")
    );

    const daoFactory = await ethers.getContractFactory("DAO");
    const dao: DAO = await daoFactory.deploy(
        token.address,
        config.dao.minimumQuorum,
        config.dao.debatingDuration
    )
    await dao.deployed();

    await token.connect(thisObject.user1).approve(
        dao.address, 
        ethers.utils.parseEther("1000000")
    );
    await token.connect(thisObject.user2).approve(
        dao.address, 
        ethers.utils.parseEther("1000000")
    );
    await token.connect(thisObject.user3).approve(
        dao.address, 
        ethers.utils.parseEther("1000000")
    );
    await token.connect(thisObject.user4).approve(
        dao.address, 
        ethers.utils.parseEther("1000000")
    );
    await token.connect(thisObject.user5).approve(
        dao.address, 
        ethers.utils.parseEther("1000000")
    );
    await token.connect(thisObject.user6).approve(
        dao.address, 
        ethers.utils.parseEther("1000000")
    );
    await token.connect(thisObject.user7).approve(
        dao.address, 
        ethers.utils.parseEther("1000000")
    );
    
    return [dao, token];
}
