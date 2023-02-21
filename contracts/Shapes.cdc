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

    // Event emited whenever a new Collection is created
    pub event CollectionCreated(to: Address?)
    //------------------------------------------------------------------------------

    //------------ CONTRACT INTERFACES ---------------------------------------------
    // Interface to establish the Shape NFTs. Very similar to the standard NFT from NonFungibleToken.NFT one
    pub resource interface INFT {
        pub let id: UInt64
        pub let score: UInt64

        // This one is used to keep tract of each shape in the same format as most collectible do, like 1/100, 177/200, etc.
        pub let nftCount: UInt64
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

        // Implement a set of paths to store these collections in the user's account
        pub let collectionStorage: StoragePath
        pub let collectionPublic: PublicPath
        
        // The main score associated to the user, via its own Collection
        pub var score: UInt64

        /*
            A way to establish control regarding maintaining a single Shape in this collection is to establish a dedicated deposit function per shape
            In that sense, to prevent the deposit of a new shape when one is already there, this function can return a shape back, which is simply the
            input one if variable is already occupided
        */
        pub fun depositSquare(square: @Square): Void {
            pre {
                // If there's a shape already there, the condition evaluates to false and returns the message
                self.mySquare == nil: "There's a Square already stored this Collection! Cannot deposit another one!"
                
                // And this is how we can enforce only one shape per Collection. The deposit function can only occur when nothing is stored in the Collection
                // to begin with. Also, this also implies that, in order to deposit another shape, the existing one needs to be withdraw first
                self.myTriangle == nil && self.myPentagon == nil && self.myCircle == nil && self.myStar == nil: 
                    "There is another shape already stored in this Collection! Cannot deposit another one!"
            }
        }

        // The remaining ones are more of the same
        pub fun depositTriangle(triangle: @Triangle): Void {
            pre{
                self.myTriangle == nil: "There's a Triangle already stored in this Collection! Cannot deposit another one!"

                self.mySquare == nil && self.myPentagon == nil && self.myCircle == nil && self.myStar == nil:
                    "There is another shape already stored in this Collection! Cannot deposit another one!"
            }
        }

        pub fun depositPentagon(pentagon: @Pentagon): Void {
            pre{
                self.myPentagon == nil: "There's a Pentagon already stored in this Collection! Cannot deposit another one!"

                self.mySquare == nil && self.myTriangle == nil && self.myCircle == nil && self.myStar == nil :
                    "There is another shape already stored in this Collection! Cannot deposit another one!"
            }
        }

        pub fun depositCircle(circle: @Circle): Void {
            pre{
                self.myCircle == nil: "There's a Circle already stored in this Collection! Cannot deposit another one!"

                self.mySquare == nil && self.myTriangle == nil && self.myPentagon == nil && self.myStar == nil:
                    "There is another shape already stored in this Collection! Cannot deposit another one!"
            }
        }

        pub fun depositStar(star: @Star): Void {
            pre{
                self.myStar == nil: "There is a Star already stored in this Collection! Cannot deposit another one!"

                self.mySquare == nil && self.myTriangle == nil && self.myPentagon == nil && self.myCircle == nil:
                    "There is another shape already stored in this Collection! Cannot deposit another one!"
            }
        }

        // Typical getID function, but this one reflects this context, i. e., the function returns a single ID for the shape stored in the collection,
        // irregardless of the type of the shape itself, or nil if there are no shapes stored in it yet
        pub fun getShapeID(): UInt64?

        // Similar function to retrieve the type of the Shape stored. This one returns the Type itself, nil if no shapes are stored yet
        pub fun getShapeType(): Type?

        // And this one returns the String representation of the Type.
        pub fun getShapeIdentifier(): String?

        // Now we need a set of borrowNFT functions. But since each of these Collections only have one of five shapes, it is more efficient to borrow the
        // shape reference by providing the shape type rather than the id. The functions returns a reference to the shpe or nil if no shapes are stored in
        // the Collection yet
        pub fun borrowSquare(): &Square?
        pub fun borrowTriangle(): &Triangle?
        pub fun borrowPentagon(): &Pentagon?
        pub fun borrowCircle(): &Circle?
        pub fun borrowStar(): &Star?

        /*
            And now for the corresponding withdraw functions. These are tricky, mainly regarding the access control. For now they are limited to access(contract)
            so that it can only be executed by an Admin resource. Like before, its pointless to receive any inputs like an ID because either the shape exists,
            or it does not. 
            TODO: These ones need extensive testing
        */
        access(contract) fun withdrawSquare(): @Square {
            pre {
                self.mySquare == nil: "There are no Squares in this Collection. Cannot withdraw!"
            }
        }

        access(contract) fun withdrawTriangle(): @Triangle {
            pre {
                self.myTriangle == nil: "There are no Triangles in this Collection. Cannot withdraw!"
            }
        }

        access(contract) fun withdrawPentagon(): @Pentagon {
            pre {
                self.myPentagon == nil: "There are no Pentagons in this Collection. Cannot withdraw!"
            }
        }

        access(contract) fun withdrawCircle(): @Circle {
            pre {
                self.myCircle == nil: "There are no Circles in this Collection. Cannot withdraw!"
            }
        }

        access(contract) fun withdrawStar(): @Star {
            pre {
                self.myStar == nil: "There are no Stars in this Collection. Cannot withdraw!"
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
        pub let nftCount: UInt64

        pub fun getID(): UInt64 {
            return self.id
        }

        init(count: UInt64) {
            self.id = self.uuid
            self.score = 1
            self.nftCount = count
        }
    }

    pub resource Triangle: INFT {
        pub let id: UInt64
        pub let score: UInt64
        pub let nftCount: UInt64

        init(count: UInt64) {
            self.id = self.uuid
            self.score = 2
            self.nftCount = count
        }
    }

    pub resource Pentagon: INFT {
        pub let id: UInt64
        pub let score: UInt64
        pub let nftCount: UInt64

        init(count: UInt64) {
            self.id = self.uuid
            self.score = 3
            self.nftCount = count
        }
    }

    pub resource Circle: INFT {
        pub let id: UInt64
        pub let score: UInt64
        pub let nftCount: UInt64

        init(count: UInt64) {
            self.id = self.uuid
            self.score = 4
            self.nftCount = count
        }
    }

    pub resource Star: INFT {
        pub let id: UInt64
        pub let score: UInt64
        pub let nftCount: UInt64

        init(count: UInt64) {
            self.id = self.uuid
            self.score = 5
            self.nftCount = count
        }
    }

    pub resource Collection: ICollection {
        pub var mySquare: @Square?
        pub var myTriangle: @Triangle?
        pub var myPentagon: @Pentagon?
        pub var myCircle: @Circle?
        pub var myStar: @Star?

        pub let collectionStorage: StoragePath
        pub let collectionPublic: PublicPath

        pub var score: UInt64

        // Now the deposit functions
        pub fun depositSquare(square: @Square): Void {
            // The mechanics to ensure that only one Square (or any other shape) are in this collection at a time were defined in the interface above.
            // At this point we need only to store the shape received in the correct place in the Collection
            
            // Update the collection score with the one received by the shape input
            self.score = self.score + square.score

            // And store it internally first
            self.mySquare <-! square
        }

        pub fun depositTriangle(triangle: @Triangle): Void {
            self.score = self.score + triangle.score
            self.myTriangle <-! triangle
        }

        pub fun depositPentagon(pentagon: @Pentagon): Void {
            self.score = self.score + pentagon.score
            self.myPentagon <-! pentagon
        }

        pub fun depositCircle(circle: @Circle): Void {
            self.score = self.score + circle.score
            self.myCircle <-! circle
        }

        pub fun depositStar(star: @Star): Void {
            self.score = self.score + star.score
            self.myStar <-! star
        }

        // The get id function checks each shape position and returns the id of the first one found. The assumption is that only one shape exists in the collection
        // at a time, or none (which returns a nil)
        pub fun getShapeID(): UInt64? {
            if (self.mySquare != nil) {
                // We don't/can't mess around with the stored resource, to get a reference to it intead
                let squareRef: &Square = (&self.mySquare as &Square?)!

                // And we can then return the id safely
                return squareRef.id
            }
            
            if (self.myTriangle != nil) {
                let triangleRef: &Triangle = (&self.myTriangle as &Triangle?)!
                return triangleRef.id
            }

            if (self.myPentagon != nil) {
                let pentagonRef: &Pentagon = (&self.myPentagon as &Pentagon?)!
                return pentagonRef.id
            }

            if (self.myCircle != nil) {
                let circleRef: &Circle = (&self.myCircle as &Circle?)!
                return circleRef.id
            }

            if (self.myStar != nil) {
                let starRef: &Star = (&self.myStar as &Star?)!
                return starRef.id
            }

            return nil
        }

        // Same logic for the following set of information retrieval functions
        pub fun getShapeType(): Type? {
            if (self.mySquare != nil) {
                // In this case, because the getType() function is somewhat agnostic, we can return the type with needing to get a reference first
                return self.mySquare.getType()
            }

            if (self.myTriangle != nil) {
                return self.myTriangle.getType()
            }

            if (self.myPentagon != nil) {
                return self.myPentagon.getType()
            }

            if (self.myCircle != nil) {
                return self.myCircle.getType()
            }

            if (self.myStar != nil) {
                return self.myStar.getType()
            }

            // If the code does not hit any of the previous ifs, return a nil isntead. It means that no shape is stored in this collection yet
            return nil
        }

        // Just like the getType() function is not conditioned to a cast reference, so does the type's identifier
        pub fun getShapeIdentifier(): String? {
            if (self.mySquare != nil) {
                return self.mySquare.getType().identifier
            }

            if (self.myTriangle != nil) {
                return self.myTriangle.getType().identifier
            }

            if (self.myPentagon != nil) {
                return self.myPentagon.getType().identifier
            }

            if (self.myCircle != nil) {
                return self.myCircle.getType().identifier
            }

            if (self.myStar != nil) {
                return self.myStar.getType().identifier
            }

            return nil
        }

        // And now for the borrow functions. These are the simpliest one. Just return the optional reference. Its up to the caller to check if these are nil or not
        // There no need to go for the redundant process of checking if the shape exist first and all the casting process
        pub fun borrowSquare(): &Square? {
            return &self.mySquare as &Square?
        }

        pub fun borrowTriangle(): &Triangle? {
            return &self.myTriangle as &Triangle?
        }

        pub fun borrowPentagon(): &Pentagon? {
            return &self.myPentagon as &Pentagon?
        }

        pub fun borrowCircle(): &Circle? {
            return &self.myCircle as &Circle?
        }

        pub fun borrowStar(): &Star? {
            return &self.myStar as &Star?
        }

        // And the conditioned withdraw functions
        access(contract) fun withdrawSquare(): @Square {
            // As with the deposit functions, the pre conditions implemented in the Interface above take care of guaranteeing that a shape exists in the Collection
            // If the code gets here, there is a shape in the variable in question
            var squareToReturn: Never? = nil

            squareToReturn <-> self.mySquare
            return <- squareToReturn
        }

        init() {
            // Initialize all inner shapes to nil. These can only get here from a Admin transfer
            self.mySquare <- nil
            self.myTriangle <- nil
            self.myPentagon <- nil
            self.myCircle <- nil
            self.myStar <- nil

            self.collectionStorage = /storage/ShapeCollection
            self.collectionPublic = /public/ShapeCollection

            // Score initialized at 0, as expected
            self.score = 0
        }

        // The usual destructor
        destroy() {
            destroy self.mySquare
            destroy self.myTriangle
            destroy self.myPentagon
            destroy self.myCircle
            destroy self.myStar
        }
    }

    // And now for the main Collection resource, which follows the interface defined above
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

    // The usual function to create an empty collection
    pub fun createEmptyCollection(): @Collection {
        return <- create Collection()
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
 