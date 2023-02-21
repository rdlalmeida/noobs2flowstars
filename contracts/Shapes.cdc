/*
    Main contract to establish the Shapes resources and associated mechanism. The contract establish a series of
    NFTs under the NonFungibleToken standard.

    The total supply of each shape is going to be bound with a contract variable and enforced with a function that
    regulates mints, i.e., mints for a given shape can only happen if the count for that shape <= maxCount (also
    established as contract constant)

    Ricardo Almeida Feb/2023

*/

// Omit this contract because I need to setup my own flavour of Collections. The NFTs, not so much
// import NonFungibleToken from "../../common_resources/contracts/NonFungibleToken.cdc"

pub contract Shapes {
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

    /*
        Dictionaries to store the minted shapes for future distribution
        NOTE 1: We can keep note of how many shapes are "out there", i.e., transferred for external accounts by subtracting the
        length of these dictionaries (the shapes that are still in our possession) from the total supply of that shape.
        NOTE 2: These dictionaries have access(account) permissions so that they can only transferred from the main contract
        via an admin resource (to be created later) that only the contract deployer can access (saved in private storage)
    */
    access(account) var ownedSquares: @{UInt64: Square}
    access(account) var ownedTriangles: @{UInt64: Triangle}
    access(account) var ownedPentagons: @{UInt64: Pentagon}
    access(account) var ownedCircles: @{UInt64: Circle}
    access(account) var ownedStars: @{UInt64: Star}
    //------------------------------------------------------------------------------

    //------------ CONTRACT EVENTS -------------------------------------------------
    // Event for when the contract is initialized (deployed successfully)
    pub event ContractInitialized()

    // Event emited whenever a shape is transfered from this contract Collection to a user.
    // The event indicates the type of shape transferred
    pub event ShapeDeposit(id: UInt64, shapeType: String, to: Address?)

    // Event emited whenever a shape is deposited back to the contract 
    pub event ShapeWithdraw(id: UInt64, shapeType: String, from: Address?)
    //------------------------------------------------------------------------------

    //------------ CONTRACT INTERFACES ---------------------------------------------
    // Interface to establish the Shape NFTs. Very similar to the standard NFT from NonFungibleToken.NFT one
    pub resource interface INFT {
        pub let id: UInt64
        pub let score: UInt64

    }

    /*
        Interface to establish the Collection to store the received NFTs. This Collection has the particularity of storing only one shape at a time
        This mechanic is established by, first, allowing only one type of shape per collection, instead of the usual ownedNFTs dictionary and, second,
        functions that regulate the deposit of the Shape NFTs in it, as well as withdraws.
    */
    pub resource interface ICollection {
        pub var mySquare: @Square?
        pub var myTriangle: @Triangle?
        pub var myPentagon: @Pentagon?
        pub var myCircle: @Circle?
        pub var myStar: @Star?

        /*
            A way to establish control regarding maintaining a single Shape in this collection is to establish a dedicated deposit function per shape
            In that sense, to prevent the deposit of a new shape when one is already there, this function can return a shape back, which is simply the
            input one if variable is already occupided
        */
        pub fun depositSquare(square: @Square): Void {
            pre {
                // If there's a shape already there, the condition evaluates to false and returns the message
                self.mySquare == nil: "There is a Square already stored this Collection! Cannot deposit another one!"
                
                // And this is how we can enforce only one shape per Collection. The deposit function can only occur when nothing is stored in the Collection
                // to begin with. Also, this also implies that, in order to deposit another shape, the existing one needs to be withdraw first
                self.myTriangle == nil && self.myPentagon == nil && self.myCircle == nil && self.myStar == nil: 
                    "There is a shape already stored in this Collection! Cannot deposit another one!"
            }
        }
    }
    //------------------------------------------------------------------------------

    //------------ NFT RESOURCES ---------------------------------------------------
    // Next, the main shapes resources definitions
    pub resource Square: INFT {
        // The usual id of the resource
        pub let id: UInt64

        pub let score: UInt64

        init() {
            self.id = self.uuid
            self.score = 1            
        }
    }

    pub resource Triangle: INFT {
        pub let id: UInt64
        pub let score: UInt64

        init() {
            self.id = self.uuid
            self.score = 2
        }
    }

    pub resource Pentagon: INFT {
        pub let id: UInt64
        pub let score: UInt64

        init() {
            self.id = self.uuid
            self.score = 3
        }
    }

    pub resource Circle: INFT {
        pub let id: UInt64
        pub let score: UInt64

        init() {
            self.id = self.uuid
            self.score = 4
        }
    }

    pub resource Star: INFT {
        pub let id: UInt64
        pub let score: UInt64

        init() {
            self.id = self.uuid
            self.score = 5
        }
    }
    //------------------------------------------------------------------------------
    
    //------------ CONTRACT FUNCTIONS ----------------------------------------------
    // Simple function to extract the string type without the 'A.<contract_address>.' part, returning just the 
    // String representation of the type
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

        // Initialize the inner storage dictionaries
        self.ownedSquares <- {}
        self.ownedTriangles <- {}
        self.ownedPentagons <- {}
        self.ownedCircles <- {}
        self.ownedStars <- {}

        // TODO: Create a special Admin Collection and mint all shapes into it (this one is not limited to the number of shapes in it)
    }
 }
 