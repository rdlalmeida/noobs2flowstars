/*
    Main contract to establish the Shapes resources and associated mechanism. The contract establish a series of
    NFTs under the NonFungibleToken standard.

    The total supply of each shape is going to be bound with a contract variable and enforced with a function that
    regulates mints, i.e., mints for a given shape can only happen if the count for that shape <= maxCount (also
    established as contract constant)

    Ricardo Almeida Feb/2023

*/

import NonFungibleToken from "../../common_resources/contracts/NonFungibleToken.cdc"

pub contract Shapes: NonFungibleToken {
    //------------ CONTRACT VARIABLES AND CONSTANTS --------------------------------
    // Set of variables to keep up with the number of shapes "out there"
    pub var totalSupply: UInt64
    pub let maxSupply: UInt64

    pub var squareTotalSupply: UInt64
    pub let maxSquares: UInt64

    pub var triangleTotalSupply: UInt64
    pub let maxTriangles: UInt64

    pub var pentagonTotalSupply: UInt64
    pub let maxPentagons: UInt64

    pub var circleTotalSupply: UInt64
    pub let maxCircles: UInt64

    pub var starTotalSupply: UInt64
    pub let maxStars: UInt64
    //------------------------------------------------------------------------------

    //------------ CONTRACT EVENTS -------------------------------------------------
    // Event for when the contract is initialized (deployed successfully)
    pub event ContractInitialized()

    // Event emited when a token is withdraw from a collection (default)
    pub event Withdraw(id: UInt64, from: Address?)

    // Event emited when a token is deposited in a collection (default)
    pub event Deposit(id: UInt64, to: Address?)

    // Event emited whenever a shape is transfered from this contract Collection to a user.
    // The event indicates the type of shape transferred
    pub event ShapeDeposit(id: UInt64, shapeType: String, to: Address?)

    // Event emited whenever a shape is deposited back to the contract 
    pub event ShapeWithdraw(id: UInt64, shapeType: String, from: Address?)
    //------------------------------------------------------------------------------
    
    //------------ NFT RESOURCES ---------------------------------------------------
    // Next, the main shapes resources definitions
    pub resource Square: NonFungibleToken.INFT {
        // The usual id of the resource
        pub let id: UInt64

        pub let score: UInt64
    }
    //------------------------------------------------------------------------------
    
    //------------ CONTRACT FUNCTIONS ----------------------------------------------
    // Simple function to extract the string type without the 'A.<contract_address>.' part, returning just the 
    // String representation of the type

    // Result of Resource.getType().identifier
    // TestNFT type is A.f8d6e0586b0a20c7.TestContract.TestNFT"
    // Result of self.account.address.toString
    // "Deployer address is 0xf8d6e0586b0a20c7"
    pub fun getShortType(shapeType: Type): String {
        // Get the String representation of the shape type
        let longType: String = shapeType.identifier

        // Get a string with the initial part to remove from the type
    }
    //------------------------------------------------------------------------------
    

    init() {
        // Initialize the counting variables to 0
        self.totalSupply = 0
        self.squareTotalSupply = 0
        self.triangleTotalSupply = 0
        self.pentagonTotalSupply = 0
        self.circleTotalSupply = 0
        self.starTotalSupply = 0

        // Set the maximum count constants to the predefined values. These can change in the future if the demand requires it.
        // Since these are set with a "let", they can only be changed with a contract update, which can only be done by the contract
        // deployer (admin)
        self.maxSquares = 5000
        self.maxTriangles = 2500
        self.maxPentagons = 1250
        self.maxCircles = 625
        self.maxStars = 100
        self.maxSupply = self.maxCircles + self.maxTriangles + self.maxPentagons + self.maxCircles + self.maxStars

        // TODO: Create a special Admin Collection and mint all shapes into it (this one is not limited to the number of shapes in it)
    }
 }
 