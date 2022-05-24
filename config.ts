import { BigNumber } from "ethers"

export default {
    dao: {
        minimumQuorum: BigNumber.from("50"),
        debatingDuration: BigNumber.from("259200")
    },

    token: {
        name: "Some token name",
        symbol: "STN"
    }
}