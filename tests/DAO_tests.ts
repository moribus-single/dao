import { expect, use } from "chai"
import { ethers, waffle } from "hardhat"
import { deploy, prepareSigners } from "./utils/prepare"
import config from "../config"

use(waffle.solidity)

describe("DAO contract", function () {
    beforeEach(async function () {
        await prepareSigners(this)
        await deploy(this, this.owner)
    })

    describe("Deployment", function () {
        it("Should assign parameters to the contracts", async function () {
            expect(
                await this.dao.asset()
            ).eq(this.token.address);
            expect(
                await this.dao.minimumQuorum()
            ).eq(config.dao.minimumQuorum.mul(await this.token.totalSupply()).div(100));
            expect(
                await this.dao.debatingDuration()
            ).eq(config.dao.debatingDuration);
            expect(
                await this.token.name()
            ).eq(config.token.name);
            expect(
                await this.token.symbol()
            ).eq(config.token.symbol);
        })
    })

    describe("Transactions", function () {
        it("", async function () {
            
        })

        it("", async function () {
            
        })

        it("", async function () {
            
        })
    })
})
