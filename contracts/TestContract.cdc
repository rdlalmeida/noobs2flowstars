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

    pub fun getShortType(shapeType: Type): String {
        // Get the String representation of the shape type
        var longType: String = shapeType.identifier

        // Get the string representation of the current address and remove the '0x' from the beginning of it
        let shortAddress: String = self.account.address.toString().slice(from: 2, upTo: self.account.address.toString().length)

        // Compose the part that I want to remove from the general type
        let pieceToRemove: String = "A.".concat(shortAddress).concat(".")

        // Use the length of the piece to remove to slice the type String

        return longType.slice(from: pieceToRemove.length,  upTo: longType.length)
    }
}