import { expect, use } from "chai"
import { ethers, waffle } from "hardhat"
import { DAO, Token } from "../build/typechain"
import { BigNumber } from "ethers"
import { prepare, prepareSigners } from "./utils/prepare"
import { increase } from "./utils/time"
import Errors from "./utils/errors"
import Events from "./utils/events"
import config from "../config"

use(waffle.solidity)

describe("DAO contract", function () {
    let dao: DAO;
    let token: Token;

    enum Result {
        UNDEFINED,
        ACCEPTED,
        DENIED
    };

    before(async function (this) {
        await prepareSigners(this)
        let contracts = await prepare(this, this.owner)
        dao = contracts[0];
        token = contracts[1]

        await dao.connect(this.user1).deposit(await token.balanceOf(this.user1.address));
        await dao.connect(this.user2).deposit(await token.balanceOf(this.user2.address));
        await dao.connect(this.user3).deposit(await token.balanceOf(this.user3.address));
        await dao.connect(this.user4).deposit(await token.balanceOf(this.user4.address));
        await dao.connect(this.user5).deposit(await token.balanceOf(this.user5.address));
        await dao.connect(this.user6).deposit(await token.balanceOf(this.user6.address));
        await dao.connect(this.user7).deposit(await token.balanceOf(this.user7.address));
    })

    describe("Deployment", function() {
        it("Should assign parameters to the DAO contract", async function () {
            expect(
                await dao.asset()
            ).eq(token.address);
        });

        it("Should assign minimum quorum to the DAO contract", async function () {
            expect(
                await dao.minimumQuorum()
            ).eq(config.dao.minimumQuorum.mul(await token.totalSupply()).div(100));
        });

        it("Should assign debating period duration to the DAO contract", async function () {
            expect(
                await dao.debatingDuration()
            ).eq(config.dao.debatingDuration);
        });

        it("Should assign name to the token contract", async function () {
            expect(
                await token.name()
            ).eq(config.token.name);
        });

        it("Should assign symbol to the token contract", async function () {
            expect(
                await token.symbol()
            ).eq(config.token.symbol);
        });
    });

    describe("addProposal", function() {
        it("Should revert if selector is not allowed", async function() {
            const funcSign = token.interface.encodeFunctionData(
                "transfer", 
                [
                    this.user2.address,
                    ethers.utils.parseEther("9999999999999999999999999999999999999999")
                ]
            )

            let tx = dao.connect(this.user2).addProposal(
                token.address,
                "add new selector for transfering money",
                funcSign
            );
            await expect(tx).revertedWith(Errors.InvalidSelector)
        });

        it("Should add proposal for adding selector", async function() {
            const transferSelector = token.interface.encodeFunctionData(
                "transfer", 
                [
                    ethers.constants.AddressZero,
                    0
                ]
            ).slice(0, 10);

            const funcSign = dao.interface.encodeFunctionData(
                "addSupportedSelector",
                [
                    ethers.utils.arrayify(transferSelector)
                ]
            )
            
            const tx = dao.connect(this.user2).addProposal(
                dao.address,
                "add new selector for transfering money",
                funcSign
            );
            await expect(tx).emit(dao, Events.addedProposal).withArgs(
                0,
                funcSign
            );

            let id = await dao.proposalId()
            expect(id).eq(1);
        });

        it("Should add proposal for setting minimal quorum", async function() {
            const funcSign = dao.interface.encodeFunctionData(
                "setMinimalQuorum",
                [
                    4
                ]
            )
            
            const tx = dao.connect(this.user2).addProposal(
                dao.address,
                "set",
                funcSign
            );

            await expect(tx).emit(dao, Events.addedProposal).withArgs(
                1,
                funcSign
            );
        });

        it("Should add proposals for invalid callData", async function() {
            const transferFromSelector = token.interface.encodeFunctionData(
                "transferFrom",
                [
                    ethers.constants.AddressZero,
                    ethers.constants.AddressZero,
                    0
                ]
            ).slice(0, 10);

            const funcSign = dao.interface.encodeFunctionData(
                "addSupportedSelector",
                [
                    ethers.utils.arrayify(transferFromSelector)
                ]
            );

            let tx = dao.connect(this.user2).addProposal(
                token.address,
                "set",
                funcSign
            );

            await expect(tx).emit(dao, Events.addedProposal).withArgs(
                2,
                funcSign
            );
            

            tx = dao.connect(this.user3).addProposal(
                token.address,
                "set",
                funcSign
            );

            await expect(tx).emit(dao, Events.addedProposal).withArgs(
                3,
                funcSign
            );
        });
    });

    describe("vote", function() {
        it("Should revert if invalid ID is provided", async function() {
            const tx = dao.connect(this.user1).vote(5, true);
            await expect(tx).revertedWith(Errors.InvalidProposalId);
        });

        it("Should revert if user trying to vote twice", async function() {
            await dao.connect(this.user1).vote(0, true);

            let tx = dao.connect(this.user1).vote(0, false);
            await expect(tx).revertedWith(Errors.InvalidVote);
        });

        it("Should revert if user trying to withdraw, but he is in voting", async function() {
            let tx = dao.connect(this.user1).withdraw();
            await expect(tx).revertedWith(Errors.UserTokensLocked)
        });

        it("Shouldn't revert when any user want to vote in first time", async function() {
            let tx = dao.connect(this.user2).vote(0, true);
            await expect(tx).not.reverted;

            tx = dao.connect(this.user3).vote(0, false);
            await expect(tx).not.reverted;

            tx = dao.connect(this.user4).vote(0, true);
            await expect(tx).not.reverted;

            tx = dao.connect(this.user5).vote(0, true);
            await expect(tx).not.reverted;


            tx = dao.connect(this.user2).vote(1, true);
            await expect(tx).not.reverted;

            tx = dao.connect(this.user3).vote(1, true);
            await expect(tx).not.reverted;

            tx = dao.connect(this.user4).vote(1, true);
            await expect(tx).not.reverted;

            tx = dao.connect(this.user5).vote(1, true);
            await expect(tx).not.reverted;


            tx = dao.connect(this.user2).vote(2, true);
            await expect(tx).not.reverted;

            tx = dao.connect(this.user3).vote(2, true);
            await expect(tx).not.reverted;

            tx = dao.connect(this.user4).vote(2, true);
            await expect(tx).not.reverted;

            tx = dao.connect(this.user5).vote(2, true);
            await expect(tx).not.reverted;

            
            tx = dao.connect(this.user2).vote(3, false);
            await expect(tx).not.reverted;

            tx = dao.connect(this.user3).vote(3, false);
            await expect(tx).not.reverted;

            tx = dao.connect(this.user4).vote(3, false);
            await expect(tx).not.reverted;

            tx = dao.connect(this.user5).vote(3, false);
            await expect(tx).not.reverted;
        });
    });

    describe("finishProposal", function() {
        it("Should revert if not enough time has gone", async function() {
            const tx = dao.finishProposal(0);
            await expect(tx).revertedWith(Errors.CannotBeFinished);
        });

        it("Shouldn't revert if proposal accepted", async function() {
            const transferSelector = token.interface.encodeFunctionData(
                "transfer", 
                [
                    ethers.constants.AddressZero,
                    0
                ]
            ).slice(0, 10);
            await increase(BigNumber.from("259200"));

            const tx = dao.finishProposal(0);
            await expect(tx).emit(dao, Events.finishedProposal)
            .withArgs(0, Result.ACCEPTED);

            expect(
                await dao.isSupportedSelector(ethers.utils.arrayify(transferSelector))
            ).true;
        });

        it("Shouldn't revert while proposal ", async function() {
            const tx = dao.finishProposal(1);
            await expect(tx).emit(dao, Events.finishedProposal)
            .withArgs(1, Result.ACCEPTED);
        });

        it("Should revert while proposal accepted and call is invalid", async function() {
            await increase(BigNumber.from("2592000"));
            const tx = dao.finishProposal(2);
            await expect(tx).revertedWith(Errors.InvalidCall);
        });

        it("Shouldn't revert while proposal with invalid call is denied", async function() {
            const tx = dao.finishProposal(3);
            await expect(tx).emit(dao, Events.finishedProposal)
            .withArgs(3, Result.DENIED);
        })
    });

    describe("withdraw", function() {
        it("withdraw after voting is finished", async function() {
            const balanceBefore = await token.balanceOf(this.user2.address);

            let tx = dao.connect(this.user2).withdraw()
            await expect(tx).not.reverted;

            const balanceAfter = await token.balanceOf(this.user2.address);
            expect(balanceAfter.sub(balanceBefore)).eq(ethers.utils.parseEther("1000000"))
        });
    });

    describe("integrational test", function() {
        it("adding new proposal for setting debating period", async function() {
            const funcSign = dao.interface.encodeFunctionData(
                "setDebatingPeriod",
                [
                    60*60*24*2
                ]
            );

            const tx = dao.connect(this.user2).addProposal(
                dao.address,
                "set debating period to 2 days",
                funcSign
            );

            await expect(tx).emit(dao, Events.addedProposal).withArgs(
                4,
                funcSign
            );
        });

        it("voting for the proposal (debating period)", async function() {
            let tx = dao.connect(this.user1).vote(4, true);
            await expect(tx).not.reverted;

            tx = dao.connect(this.user2).vote(4, true);
            await expect(tx).not.reverted;

            tx = dao.connect(this.user3).vote(4, true);
            await expect(tx).not.reverted;

            tx = dao.connect(this.user4).vote(4, true);
            await expect(tx).not.reverted;

            tx = dao.connect(this.user5).vote(4, false);
            await expect(tx).not.reverted;

            // try to withdraw
            tx = dao.connect(this.user5).withdraw();
            await expect(tx).revertedWith(Errors.UserTokensLocked);

            // try to withdraw
            tx = dao.connect(this.user5).deposit(100);
            await expect(tx).revertedWith(Errors.UserTokensLocked);

            // try to vote twice
            tx = dao.connect(this.user5).vote(4, false);
            await expect(tx).revertedWith(Errors.InvalidVote);

            tx = dao.connect(this.user4).vote(4, false);
            await expect(tx).revertedWith(Errors.InvalidVote);

            tx = dao.connect(this.user3).vote(4, true);
            await expect(tx).revertedWith(Errors.InvalidVote)

            tx = dao.connect(this.user2).vote(4, true);
            await expect(tx).revertedWith(Errors.InvalidVote)

            tx = dao.connect(this.user1).vote(4, true);
            await expect(tx).revertedWith(Errors.InvalidVote)

            // try to vote for 1 proposal
            tx = dao.connect(this.user3).vote(0, true);
            await expect(tx).revertedWith(Errors.InvalidVote)
        });

        it("finishing proposal (debating period)", async function() {
            let tx = dao.finishProposal(4);
            await expect(tx).revertedWith(Errors.CannotBeFinished)

            await increase(await dao.debatingDuration());

            // Minimum quorum is 4%, it is less, than user1 vote power.
            tx = dao.finishProposal(4);
            await expect(tx).emit(dao, Events.finishedProposal)
            .withArgs(4, Result.ACCEPTED);

            expect(await dao.debatingDuration()).eq(60*60*24*2);
        });

        it("trying to vote again in the finished proposal", async function () {
            let tx = dao.connect(this.user6).vote(4, true);
            await expect(tx).revertedWith(Errors.InvalidVote);

            tx = dao.connect(this.user7).vote(4, true);
            await expect(tx).revertedWith(Errors.InvalidVote);
        });

        it("trying to finish already finished proposal", async function () {
            let tx = dao.finishProposal(4);
            await expect(tx).revertedWith(Errors.CannotBeFinished);
        });
    });

    describe("Delegating test", function() {
        it("add some proposal", async function() {
            const funcSign = dao.interface.encodeFunctionData(
                "setMinimalQuorum",
                [
                    48
                ]
            )

            await dao.connect(this.user2).addProposal(
                dao.address,
                "set minimal quorum to 48",
                funcSign
            );
        });

        it("Should delegate to user2 from user1", async function () {
            const user = await dao.connect(this.user1).user();
            const tx = dao.connect(this.user1).delegate(5, this.user2.address);
            await expect(tx).emit(dao, Events.delegatedVotes).withArgs(
                this.user1.address,
                this.user2.address,
                5,
                user.amount
            );
        });

        it("Should revert if user delegate twice", async function () {
            const tx = dao.connect(this.user1).delegate(5, this.user3.address);
            await expect(tx).revertedWith(Errors.InvalidDelegate)
        });

        it("Should delegate balance of the user3 and user4 to user5", async function () {
            let tx = dao.connect(this.user3).delegate(5, this.user5.address);
            await expect(tx).not.reverted;

            tx = dao.connect(this.user4).delegate(5, this.user5.address);
            await expect(tx).not.reverted;
        });

        it("Should revert if user has already delegated and trying to vote", async function () {
            let tx = dao.connect(this.user1).vote(5, true);
            await expect(tx).revertedWith(Errors.InvalidVote);

            tx = dao.connect(this.user3).vote(5, false);
            await expect(tx).revertedWith(Errors.InvalidVote);

            tx = dao.connect(this.user4).vote(5, true);
            await expect(tx).revertedWith(Errors.InvalidVote);
        });

        it("Should revert if user delegated and trying to delegate again", async function () {
            let tx = dao.connect(this.user4).delegate(5, this.user1.address);
            await expect(tx).revertedWith(Errors.InvalidDelegate);
        });

        it("Shouldn't revert if user didn't delegated to some proposal and trying to vote for the first time", async function () {
            let tx = dao.connect(this.user2).vote(5, false);
            await expect(tx).not.reverted;

            tx = dao.connect(this.user5).vote(5, true);
            await expect(tx).not.reverted;
        });

        it("Finishing proposal with delegated votes. It should be accepted", async function () {
            await increase(BigNumber.from("259200"));

            let tx = dao.finishProposal(5);
            await expect(tx).emit(dao, Events.finishedProposal)
            .withArgs(5, Result.ACCEPTED);
        });
    });
});
