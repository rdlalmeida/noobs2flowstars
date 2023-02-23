/* 
    Transaction to create a Collection in a user's account
*/

import Shapes from "../contracts/Shapes.cdc"

transaction() {
    prepare(signer: AuthAccount) {
        /*
            ----------------------------- TEST BLOCK - REMOVE IN PROD ----------------------
            This next bit is used to recreate the Collection whenever this transaction is run
            We expect to change the code that regulates the Collection resource, so to reflect those,
            any previous resources in storage need to be deleted first
            The paths to store and link the Collection Resources are set in the resource itself, so we need to create it first
        */
        let oldCollection: @AnyResource <- signer.load<@AnyResource>(from: Shapes.collectionStorage)
        destroy oldCollection

        signer.unlink(Shapes.collectionPublic)
        //  --------------------------------------------------------------------------------
        

        // Create, save and link the new collection into the user's account
        let newCollection: @Shapes.Collection <- Shapes.createEmptyCollection()
        signer.save(<- newCollection, to: Shapes.collectionStorage)
        signer.link<&Shapes.Collection>(Shapes.collectionPublic, target: Shapes.collectionStorage)
    }

    execute {

    }
}
 