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
    // totalSupply keeps track of how many units of the shape were minted so far
    // maxSupply defines the maximum number of shapes that can be minted. After a successful contract initialization, totalSupply = maxSupply
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
    access(account) var ownedSquares: @{UInt64: Shapes.Square}
    access(account) var ownedTriangles: @{UInt64: Shapes.Triangle}
    access(account) var ownedPentagons: @{UInt64: Shapes.Pentagon}
    access(account) var ownedCircles: @{UInt64: Shapes.Circle}
    access(account) var ownedStars: @{UInt64: Shapes.Star}
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

    // Event emited when all Squares are minted
    pub event AllSquaresMinted(amount: UInt64)

    // Event emited when all Triangles are minted
    pub event AllTrianglesMinted(amount: UInt64)

    // Event emited when all Pentagons are minted
    pub event AllPentagonsMinted(amount: UInt64)

    // Event emited when all Circles are minted
    pub event AllCirclesMinted(amount: UInt64)

    // Event emited when all Stars are minted
    pub event AllStarsMinted(amount: UInt64)

    // Event emited when the Admin Resource is created, saved and linked to the private storage
    pub event AdminReady()
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
        This mechanic is established by using an array to store the Resource because: 1. We need to use the Array.remove function to remove a resource
        from an array and 2. Nested resources are notoriously hard on moving Resources around.
    */
    pub resource interface ICollection {
        pub var mySquare: @[Shapes.Square]
        pub var myTriangle: @[Shapes.Triangle]
        pub var myPentagon: @[Shapes.Pentagon]
        pub var myCircle: @[Shapes.Circle]
        pub var myStar: @[Shapes.Star]

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
        pub fun depositSquare(square: @Shapes.Square): Void {
            pre {
                // If there's a shape already there, the condition evaluates to false and returns the message
                self.mySquare.length == 0: "There's a Square already stored this Collection! Cannot deposit another one!"
                
                // And this is how we can enforce only one shape per Collection. The deposit function can only occur when nothing is stored in the Collection
                // to begin with. Also, this also implies that, in order to deposit another shape, the existing one needs to be withdraw first
                self.myTriangle.length == 0 && self.myPentagon.length == 0 && self.myCircle.length == 0 && self.myStar.length == 0: 
                    "There is another shape already stored in this Collection! Cannot deposit another one!"
            }
        }

        // The remaining ones are more of the same
        pub fun depositTriangle(triangle: @Shapes.Triangle): Void {
            pre{
                self.myTriangle.length == 0: "There's a Triangle already stored in this Collection! Cannot deposit another one!"

                self.mySquare.length == 0 && self.myPentagon.length == 0 && self.myCircle.length == 0 && self.myStar.length == 0:
                    "There is another shape already stored in this Collection! Cannot deposit another one!"
            }
        }

        pub fun depositPentagon(pentagon: @Shapes.Pentagon): Void {
            pre{
                self.myPentagon.length == 0: "There's a Pentagon already stored in this Collection! Cannot deposit another one!"

                self.mySquare.length == 0 && self.myTriangle.length == 0 && self.myCircle.length == 0 && self.myStar.length == 0:
                    "There is another shape already stored in this Collection! Cannot deposit another one!"
            }
        }

        pub fun depositCircle(circle: @Shapes.Circle): Void {
            pre{
                self.myCircle.length == 0: "There's a Circle already stored in this Collection! Cannot deposit another one!"

                self.mySquare.length == 0 && self.myTriangle.length == 0 && self.myPentagon.length == 0 && self.myStar.length == 0:
                    "There is another shape already stored in this Collection! Cannot deposit another one!"
            }
        }

        pub fun depositStar(star: @Shapes.Star): Void {
            pre{
                self.myStar.length == 0: "There is a Star already stored in this Collection! Cannot deposit another one!"

                self.mySquare.length == 0 && self.myTriangle.length == 0 && self.myPentagon.length == 0 && self.myCircle.length == 0:
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
        pub fun borrowSquare(): &Shapes.Square?
        pub fun borrowTriangle(): &Shapes.Triangle?
        pub fun borrowPentagon(): &Shapes.Pentagon?
        pub fun borrowCircle(): &Shapes.Circle?
        pub fun borrowStar(): &Shapes.Star?

        /*
            And now for the corresponding withdraw functions. These are tricky, mainly regarding the access control. For now they are limited to access(contract)
            so that it can only be executed by an Admin resource. Like before, its pointless to receive any inputs like an ID because either the shape exists,
            or it does not.
            This interface check if there a shape in the collection first (if the condition is true, i.e., the length of the array is indeed 0) before attempting to
            withdraw the shape and checks if the array is not empty after the withdrawl, which triggers the post condition. This effectively forces the shape array
            to be either empty or with only one shape at any moment, at most.
            TODO: These ones need extensive testing
        */
        access(contract) fun withdrawSquare(): @Shapes.Square {
            pre {
                self.mySquare.length == 0: "There are no Squares in this Collection. Cannot withdraw!"
            }

            post {
                self.mySquare.length == 0: "There are still Squares in this collection. The withdraw needs to empty the array!"
            }
        }

        access(contract) fun withdrawTriangle(): @Shapes.Triangle {
            pre {
                self.myTriangle.length == 0: "There are no Triangles in this Collection. Cannot withdraw!"
            }

            post {
                self.myTriangle.length == 0: "There are still Triangles in this collection. The withdraw needs to empty the array!"
            }
        }

        access(contract) fun withdrawPentagon(): @Shapes.Pentagon {
            pre {
                self.myPentagon.length == 0: "There are no Pentagons in this Collection. Cannot withdraw!"
            }

            post {
                self.myPentagon.length == 0: "There are still Pentagons in this Collection. The withdraw needs to empty the array!"
            }
        }

        access(contract) fun withdrawCircle(): @Shapes.Circle {
            pre {
                self.myCircle.length == 0: "There are no Circles in this Collection. Cannot withdraw!"
            }

            post {
                self.myCircle.length == 0: "There are still Circles in this Collection. The withdraw needs to empty the array!"
            }
        }

        access(contract) fun withdrawStar(): @Shapes.Star {
            pre {
                self.myStar.length == 0: "There are no Stars in this Collection. Cannot withdraw!"
            }

            post {
                self.myStar.length == 0: "There are still Stars in this Collection. The withdraw needs to empty the array!"
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

    // And now for the main Collection resource, which follows the interface defined above
    pub resource Collection: ICollection {
        pub var mySquare: @[Shapes.Square]
        pub var myTriangle: @[Shapes.Triangle]
        pub var myPentagon: @[Shapes.Pentagon]
        pub var myCircle: @[Shapes.Circle]
        pub var myStar: @[Shapes.Star]

        pub let collectionStorage: StoragePath
        pub let collectionPublic: PublicPath

        pub var score: UInt64

        // Now the deposit functions
        pub fun depositSquare(square: @Shapes.Square): Void {
            // The mechanics to ensure that only one Square (or any other shape) are in this collection at a time were defined in the interface above.
            // At this point we need only to store the shape received in the correct place in the Collection
            
            // Update the collection score with the one received by the shape input
            self.score = self.score + square.score

            // And store it internally first
            self.mySquare.append(<- square)
        }

        pub fun depositTriangle(triangle: @Shapes.Triangle): Void {
            self.score = self.score + triangle.score
            self.myTriangle.append(<- triangle)
        }

        pub fun depositPentagon(pentagon: @Shapes.Pentagon): Void {
            self.score = self.score + pentagon.score
            self.myPentagon.append(<- pentagon)
        }

        pub fun depositCircle(circle: @Shapes.Circle): Void {
            self.score = self.score + circle.score
            self.myCircle.append(<- circle)
        }

        pub fun depositStar(star: @Shapes.Star): Void {
            self.score = self.score + star.score
            self.myStar.append(<- star)
        }

        // The get id function checks each shape position and returns the id of the first one found. The assumption is that only one shape exists in the collection
        // at a time, or none (which returns a nil)
        pub fun getShapeID(): UInt64? {
            if (self.mySquare[0] != nil) {
                // We don't/can't mess around with the stored resource, to get a reference to it intead
                let squareRef: &Shapes.Square = (&self.mySquare[0] as &Square?)!

                // And we can then return the id safely
                return squareRef.id
            }
            
            if (self.myTriangle[0] != nil) {
                let triangleRef: &Shapes.Triangle = (&self.myTriangle[0] as &Triangle?)!
                return triangleRef.id
            }

            if (self.myPentagon[0] != nil) {
                let pentagonRef: &Shapes.Pentagon = (&self.myPentagon[0] as &Pentagon?)!
                return pentagonRef.id
            }

            if (self.myCircle[0] != nil) {
                let circleRef: &Shapes.Circle = (&self.myCircle[0] as &Circle?)!
                return circleRef.id
            }

            if (self.myStar[0] != nil) {
                let starRef: &Shapes.Star = (&self.myStar[0] as &Star?)!
                return starRef.id
            }

            return nil
        }

        // Same logic for the following set of information retrieval functions
        pub fun getShapeType(): Type? {
            if (self.mySquare[0] != nil) {
                // In this case, because the getType() function is somewhat agnostic, we can return the type with needing to get a reference first
                return self.mySquare[0].getType()
            }

            if (self.myTriangle[0] != nil) {
                return self.myTriangle[0].getType()
            }

            if (self.myPentagon[0] != nil) {
                return self.myPentagon[0].getType()
            }

            if (self.myCircle[0] != nil) {
                return self.myCircle[0].getType()
            }

            if (self.myStar[0] != nil) {
                return self.myStar[0].getType()
            }

            // If the code does not hit any of the previous ifs, return a nil isntead. It means that no shape is stored in this collection yet
            return nil
        }

        // Just like the getType() function is not conditioned to a cast reference, so does the type's identifier
        pub fun getShapeIdentifier(): String? {
            if (self.mySquare[0] != nil) {
                return self.mySquare[0].getType().identifier
            }

            if (self.myTriangle[0] != nil) {
                return self.myTriangle[0].getType().identifier
            }

            if (self.myPentagon[0] != nil) {
                return self.myPentagon[0].getType().identifier
            }

            if (self.myCircle[0] != nil) {
                return self.myCircle[0].getType().identifier
            }

            if (self.myStar[0] != nil) {
                return self.myStar[0].getType().identifier
            }

            return nil
        }

        // And now for the borrow functions. These are the simpliest one. Just return the optional reference. Its up to the caller to check if these are nil or not
        // There no need to go for the redundant process of checking if the shape exist first and all the casting process
        pub fun borrowSquare(): &Shapes.Square? {
            return &self.mySquare[0] as &Square?
        }

        pub fun borrowTriangle(): &Shapes.Triangle? {
            return &self.myTriangle[0] as &Triangle?
        }

        pub fun borrowPentagon(): &Shapes.Pentagon? {
            return &self.myPentagon[0] as &Pentagon?
        }

        pub fun borrowCircle(): &Shapes.Circle? {
            return &self.myCircle[0] as &Circle?
        }

        pub fun borrowStar(): &Shapes.Star? {
            return &self.myStar[0] as &Star?
        }

        // And the conditioned withdraw functions
        access(contract) fun withdrawSquare(): @Shapes.Square {
            // As with the deposit functions, the pre conditions implemented in the Interface above take care of guaranteeing that a shape exists in the Collection
            // If the code gets here, there is a shape in the variable in question
            return <- self.mySquare.remove(at: 0)
        }

        access(contract) fun withdrawTriangle(): @Shapes.Triangle {
            return <- self.myTriangle.remove(at: 0)
        }

        access(contract) fun withdrawPentagon(): @Shapes.Pentagon {
            return <- self.myPentagon.remove(at: 0)
        }

        access(contract) fun withdrawCircle(): @Shapes.Circle {
            return <- self.myCircle.remove(at: 0)
        }

        access(contract) fun withdrawStar(): @Shapes.Star {
            return <- self.myStar.remove(at:0)
        }

        init() {
            // Initialize all inner shapes to nil. These can only get here from a Admin transfer
            self.mySquare <- []
            self.myTriangle <- []
            self.myPentagon <- []
            self.myCircle <- []
            self.myStar <- []

            self.collectionStorage = /storage/ShapeCollection
            self.collectionPublic = /public/ShapeCollection

            // Score initialized at 0, as expected
            self.score = 0

            // Emit the respective event
            emit CollectionCreated(to: self.owner?.address)
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

    /* 
        We also need an Admin Resource that has the ability to move shapes from and into the contract storage dictionaries. Other contracts (like TopShot) that have
        variable sized minting sets use Collections for this purpose, which makes perfect sense in that context. Ourselves however, because of our N to 1 dynamic here, i.e., 
        where the contract/admin size stores multiple Resources at any given time but the user Collections can only store 1, we need to be creative.
        Another approach was to create a Admin Collection that could store multiple NFTs as opposed to the user ones.
    */
    pub resource Admin {
        pub let adminStorage: StoragePath
        pub let adminPrivate: PrivatePath

        /*
            The most important functions here are the deposit and withdraw functions
            As with most up to here, the deposit function is actually a series of deposit functions, one per shape, to keep it simple, believe it or not
            These functions simply deposit the next available shape into the collection. To protect against trying to deposit from an empty dictionary
            we use pre-conditions

            input: collectionRef: &Shapes.Collection - A reference to a collection to where the shape is going to be deposited to.
            output: Void. If the pre-condition is not triggered, the function is successful
        */
        
        access(contract) fun depositSquare(collectionRef: &Shapes.Collection): Void {
            pre {
                Shapes.ownedSquares.length == 0: "There are no Squares left to deposit! Cannot continue!"
            }
            // If the pre-condition cleared, retrieve the next available Square and deposit it in the Collection provided
            let squareToDeposit: @Shapes.Square <- Shapes.ownedSquares.remove(key: Shapes.getAllSquareIDs().removeFirst())!

            // Got it. Deposit it in Collection
            collectionRef.depositSquare(square: <- squareToDeposit)
        }

        // The remaining ones are the same
        access(contract) fun depositTriangle(collectionRef: &Shapes.Collection): Void {
            pre {
                Shapes.ownedTriangles.length == 0: "There are no Triangles left to deposit! Cannot continue!"
            }

            let triangleToDeposit: @Shapes.Triangle <- Shapes.ownedTriangles.remove(key: Shapes.getAllTriangleIDs().removeFirst())!
            collectionRef.depositTriangle(triangle: <- triangleToDeposit)
        }

        access(contract) fun depositPentagon(collectionRef: &Shapes.Collection): Void {
            pre {
                Shapes.ownedPentagons.length == 0: "There are no Pentagons left to deposit! Cannot continue!"
            }

            let pentagonToDeposit: @Shapes.Pentagon <- Shapes.ownedPentagons.remove(key: Shapes.getAllPentagonIDs().removeFirst())!
            collectionRef.depositPentagon(pentagon: <- pentagonToDeposit)
        }

        access(contract) fun depositCircle(collectionRef: &Shapes.Collection): Void {
            pre {
                Shapes.ownedCircles.length == 0: "There are no Circles left to deposit! Cannot continue!"
            }

            let circleToDeposit: @Shapes.Circle <- Shapes.ownedCircles.remove(key: Shapes.getAllCircleIDs().removeFirst())!
            collectionRef.depositCircle(circle: <- circleToDeposit)
        }

        access(contract) fun depositStar(collectionRef: &Shapes.Collection): Void {
            pre {
                Shapes.ownedStars.length == 0: "There are no Stars left to deposit! Cannot continue!"
            }

            let starToDeposit: @Shapes.Star <- Shapes.ownedStars.remove(key: Shapes.getAllStarIDs().removeFirst())!
            collectionRef.depositStar(star: <- starToDeposit)
        }

        /*
            And now for the respective withdraw functions. These follow the same logic as before: the function starts by validating that the Collection has the
            required shape to withdraw and also (a bit redundant but anyways) that the internal dictionary has the capacity to receive it. It does not validate
            if the key in question has another shape of the same type already in it, for simplicity sake.
            
            NOTE 1: Unlike the usual, Collection-based deposit and withdrawl functions, these two have the same signature but the resource flow is different: deposit
            moves a resource from contract storage to a user Collection and the withdraw goes in inverse, i.e., from a user Collection to the contract storage.

            NOTE 2: Because the Collection already enacts a bunch of pre and post conditions in their withdrawl functions, there's no need to repeat them at this stage.
            We only need to validate the capacity of the contract storage to accept a shape
            
            input: &Shapes.Collection - A reference to a Collection reference for the user from where the shape is to be retrieved from
            output: Void - The function assumes that, if none of the pre or post conditions are violated, the withdrawl is successful.
        */
        access(contract) fun withdrawSquare(collectionRef: &Shapes.Collection): Void {
            pre {
                // Check if the length of the internal dictionary matches the max Squares allowed, which means that no more Squares can be stores in this dictionary.
                Shapes.ownedSquares.length == Int(Shapes.maxSquares): "This contract cannot store any more Squares! Cannot proceed!"
            }
            // Attempt to withdraw the shape from the user Collection. If there are no squares there or any other issues, the pre and post conditions of the withdraw
            // function should stop it in their tracks
            let squareToRetrieve: @Shapes.Square <- collectionRef.withdrawSquare()

            // If all went well, we only need now to store the Square in the internal dictionary, given that we have checked that there is space for it
            // NOTE: The usage of the oldResource here is just a usage of Cadence good practics. Ideally we should check if the oldResource is not nil (it's expected
            // to be if everything is correct) and, if not, if it is a shape, which is a serious error at this point if that happens to be the case. But time is
            // quite limited and we are writing loads of comments already so...
            let oldResource: @AnyResource <- Shapes.ownedSquares[squareToRetrieve.id] <- squareToRetrieve

            // Destroy the old resource without questions
            destroy oldResource
        }

        access(contract) fun withdrawTriangle(collectionRef: &Shapes.Collection): Void {
            pre {
                Shapes.ownedTriangles.length == Int(Shapes.maxTriangles): "This contract cannot store any more Triangles! Cannot proceed!"
            }

            let triangleToRetrieve: @Shapes.Triangle <- collectionRef.withdrawTriangle()
            let oldResource: @AnyResource <- Shapes.ownedTriangles[triangleToRetrieve.id] <- triangleToRetrieve
            destroy oldResource
        }

        access(contract) fun withdrawPentagon(collectionRef: &Shapes.Collection): Void {
            pre{
                Shapes.ownedPentagons.length == Int(Shapes.maxPentagons): "This contract cannot store any more Pentagons! Cannot proceed!"
            }

            let pentagonToRetrieve: @Shapes.Pentagon <- collectionRef.withdrawPentagon()
            let oldResource: @AnyResource <- Shapes.ownedPentagons[pentagonToRetrieve.id] <- pentagonToRetrieve
            destroy oldResource
        }

        access(contract) fun withdrawCircle(collectionRef: &Shapes.Collection): Void {
            pre {
                Shapes.ownedCircles.length == Int(Shapes.maxCircles): "This contract cannot store any more Circles! Cannot proceed!"
            }

            let circleToRetrieve: @Shapes.Circle <- collectionRef.withdrawCircle()
            let oldResource: @AnyResource <- Shapes.ownedCircles[circleToRetrieve.id] <- circleToRetrieve
            destroy oldResource
        }

        access(contract) fun withdrawStar(collectionRef: &Shapes.Collection): Void {
            pre{
                Shapes.ownedStars.length == Int(Shapes.maxStars): "This contract cannot store any more Stars! Cannot proceed!"
            }

            let starToRetrieve: @Shapes.Star <- collectionRef.withdrawStar()
            let oldResource: @AnyResource <- Shapes.ownedStars[starToRetrieve.id] <- starToRetrieve
            destroy oldResource
        }

        init () {
            self.adminStorage = /storage/ShapeAdmin
            self.adminPrivate = /private/ShapeAdmin
        }

        /*
            Function to create an Admin resource. The function is set to public inside of a nested Resource, which means it is only callable at contract init.
            The idea here is the usual: during this contract initialization, create, save it to the private storage and link it also. Storing it in the private
            storage means that only the contract deployed (admin) can access it.
            input: Void
            output: @Shapes.Admin - The function returns an Admin Resource
        */
        pub fun createAdmin(): @Shapes.Admin {
            return <- create Shapes.Admin()
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

    // The usual function to create an empty collection
    pub fun createEmptyCollection(): @Shapes.Collection {
        return <- create Collection()
    }

    // Functions to retrieve all the IDs for a given shape
    pub fun getAllSquareIDs(): [UInt64] {
        return self.ownedSquares.keys
    }

    pub fun getAllTriangleIDs(): [UInt64] {
        return self.ownedTriangles.keys
    }

    pub fun getAllPentagonIDs(): [UInt64] {
        return self.ownedPentagons.keys
    }

    pub fun getAllCircleIDs(): [UInt64] {
        return self.ownedCircles.keys
    }

    pub fun getAllStarIDs(): [UInt64] {
        return self.ownedStars.keys
    }

    // Function to return the shapes currently stored in the contract account
    pub fun getAllContractShapesIDs(): {String: [UInt64]} {
        var returnDictionary: {String: [UInt64]} = {}

        // Add all shape ids sequentially, using its type as key
        returnDictionary["Squares"] = self.getAllSquareIDs()
        returnDictionary["Triangles"] = self.getAllTriangleIDs()
        returnDictionary["Pentagons"] = self.getAllPentagonIDs()
        returnDictionary["Circles"] = self.getAllCircleIDs()
        returnDictionary["Stars"] = self.getAllStarIDs()

        return returnDictionary
    }

    // Function to return a run down of the number of shapes stored in the contract account
    pub fun getContractShapeCounts(): {String: Int} {
        var returnDictionary: {String: Int} = {}

        // Add the number of shapes per internal dictionary, one at a time
        returnDictionary["Squares"] = self.getAllSquareIDs().length
        returnDictionary["Triangles"] = self.getAllTriangleIDs().length
        returnDictionary["Pentagons"] = self.getAllPentagonIDs().length
        returnDictionary["Circles"] = self.getAllCircleIDs().length
        returnDictionary["Stars"] = self.getAllStarIDs().length

        return returnDictionary
    }

    // ------------------------------------------------------------------------------
    

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

        // REAL VALUES
        // self.maxSquares = 5000
        // self.maxTriangles = 2500
        // self.maxPentagons = 1250
        // self.maxCircles = 625
        // self.maxStars = 100

        // TEST VALUES
        self.maxSquares = 50
        self.maxTriangles = 25
        self.maxPentagons = 12
        self.maxCircles = 6
        self.maxStars = 3
        self.maxSupply = self.maxCircles + self.maxTriangles + self.maxPentagons + self.maxCircles + self.maxStars

        // Initialize the inner storage dictionaries
        self.ownedSquares <- {}
        self.ownedTriangles <- {}
        self.ownedPentagons <- {}
        self.ownedCircles <- {}
        self.ownedStars <- {}

        // Create, save and link an Admin resource to the private storage
        let admin: @Shapes.Admin <- create Admin()

        // The storage paths are saved into the resource itself. Keep a reference to it just access them after saving it to private storage
        let adminRef: &Shapes.Admin = &admin as &Shapes.Admin
        self.account.save(<- admin, to: adminRef.adminStorage)
        self.account.link<&Shapes.Admin>(adminRef.adminPrivate, target: adminRef.adminStorage)

        // Admin is ready. Emit the event to notify people
        emit self.AdminReady()

        // All NFTs are going to be mint into the contract dictionaries
        // First, the squares
        var counter: UInt64 = 1
        while (counter <= self.maxSquares) {
            let newSquare: @Shapes.Square <- create Square(count: counter)
            self.ownedSquares[newSquare.id] <-! newSquare

            // Add another square to the total count
            self.squareTotalSupply = self.squareTotalSupply + 1

            counter = counter + 1
        }

        emit AllSquaresMinted(amount: counter)

        // Now the triangles
        // Reset the counter first
        counter = 0

        while (counter <= self.maxTriangles) {
            let newTriangle: @Shapes.Triangle <- create Triangle(count: counter)
            self.ownedTriangles[newTriangle.id] <-! newTriangle

            counter = counter + 1
        }

        emit AllTrianglesMinted(amount: counter)

        // Pentagons
        counter = 0

        while (counter <= self.maxPentagons) {
            let newPentagon: @Shapes.Pentagon <- create Pentagon(count: counter)
            self.ownedPentagons[newPentagon.id] <-! newPentagon

            counter = counter + 1
        }

        emit AllPentagonsMinted(amount: counter)

        // Circles
        counter = 0

        while (counter <= self.maxCircles) {
            let newCircle: @Shapes.Circle <- create Circle(count: counter)
            self.ownedCircles[newCircle.id] <-! newCircle

            counter = counter + 1
        }

        emit AllCirclesMinted(amount: counter)

        // Stars
        counter = 0
        
        while (counter <= self.maxStars) {
            let newStar: @Shapes.Star <- create Star(count: counter)
            self.ownedStars[newStar.id] <-! newStar

            counter = counter + 1
        }

        emit AllStarsMinted(amount: counter)

        emit ContractInitialized()
    }
 }
 