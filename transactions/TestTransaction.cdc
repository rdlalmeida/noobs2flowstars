/*
    Simple test transaction to test stuff before implementing it
*/

import TestContract from "../contracts/TestContract.cdc"

transaction() {
    prepare(signer: AuthAccount) {
        let testNFT: @TestContract.TestNFT <- TestContract.createTestNFT()

        log("TestNFT type is ".concat(testNFT.getType().identifier))

        destroy testNFT

        log("Deployer address is ".concat(TestContract.returnDeployerAddress()))
    }

    execute {

    }
}