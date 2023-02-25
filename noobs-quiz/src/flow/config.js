import { config } from "@onflow/fcl"

config()
    .put("accessNode.api", "https://rest-testnet.onflow.org")
    .put("discovery.wallet", "https://fcl-discovery.onflow.org/testnet/authn/")
    .put("app.detail.title", "Noobs to Flowstars DApp")
    .put("app.detail.icon", "https://i.postimg.cc/44bH00zL/noobs2flowstars-logo.png")