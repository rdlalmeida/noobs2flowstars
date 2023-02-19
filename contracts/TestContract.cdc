/*
    Simple test contract for me to test stuff in the emulator
*/

pub contract TestContract {
    pub resource TestNFT{
        pub let id: UInt64
        pub let type: String

        init() {
            self.id = self.uuid
            self.type = self.getType().identifier
        }
    }

    pub fun createTestNFT(): @TestNFT {
        return <- create TestNFT()
    }

    pub fun returnDeployerAddress(): String {
        return self.account.address.toString()
    }
}