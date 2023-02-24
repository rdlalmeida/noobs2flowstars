/*
    Transaction to create a Float Event. This event should correspond to a learning event for whose the FLOAT NFTs minted should be used as proof-of-conclusion,
    as well as getting a Shape upgraded.
    These events are creating using a FLOATEvents Collection that was created and linked to the Private Storage during the Shapes.cdc contract initialization
    The inputs for this transaction are the details of the Event to create and store in the corresponding FLOAT Events Collection, namely:
        name: String - The name of the event
        description: String -  Description of the event
        image: String - A String with the image encoded in base64 (assumed)
        url: String - URL of the event
        initialGroups: [String] - An array with the names of the groups to which the event belongs. For example, an Introduction event, abstracted as a FLOATEvent, can
            belong to several organizations that which to mint FLOATs for users to prove their attendance to that particular event.
            NOTE: The group must exist before attempting to create an Event under it. Use the createGroup transaction
        verifiers: [{IVerifier}] - An array of resources that follow the IVerifier interface, which is used to implement verifiable actions such as a time window to claim
            FLOATs in the Event, passwords, etc. Check the ../../float/src/cadence/float/FLOATVerifiers.cdc contract for details
        extraMetadata: {String: AnyStruct} - Any extra metadata to add to the Event.

    For simplicity, we assume that FLOATs for the events are can be claimed (claimable = true) and non-transferable (transferable = false) by default
*/

import FLOAT from "../../float/src/cadence/float/FLOAT.cdc"
// import Shapes from "../contracts/Shapes.cdc"

transaction(name: String, description: String, image: String, url: String, initialGroups: [String], verifiers: [{FLOAT.IVerifier}], extraMetadata: {String: AnyStruct}) {
    let floatEvents: &FLOAT.FLOATEvents
    
    prepare(signer: AuthAccount) {
        // Begin by loading the FloatEvents resource reference from private storage
        self.floatEvents = signer.getCapability<&FLOAT.FLOATEvents>(FLOAT.FLOATEventsPrivatePath).borrow() ??
            panic("Account ".concat(signer.address.toString()).concat(" does not have a proper FLOATEvents collections set yet!"))
    }

    execute {
        // Create the event using the floatEvents reference
        let eventID: UInt64 = self.floatEvents.createEvent(
            claimable: true,
            description: description,
            image: image,
            name: name,
            transferrable: false,
            url: url,
            verifiers: verifiers,
            extraMetadata,
            initialGroups: initialGroups
        )
    }
}