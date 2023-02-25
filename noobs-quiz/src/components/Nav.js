import styles from "../styles/nav.css"
import * as fcl from "@onflow/fcl";
import "../flow/config.js"
import { useState, useEffect } from "react";

export default function Nav() {
    const [user, setUser] = useState({ loggedIn: false});

    useEffect(() => {
            fcl.currentUser.subscribe(setUser);
        }, []
    )

    function logInUser() {
        if (user.loggedIn) {
            alert("User ".concat(user.addr).concat(" is already logged in!"));
        }
        else {
            fcl.authenticate();
        }
    }

    function logOffUser() {
        if (user.loggedIn) {
            fcl.unauthenticate();
        }
    }

    return (
        <nav className={styles.Nav}>
            <h1>Noobs to Flowstars</h1>
            <button onClick={logInUser}>{user.loggedIn ? "Wallet ".concat(user.addr).concat(" connected!") : "Connect wallet"}</button>
            <button onClick={logOffUser}>{user.loggedIn ? "Disconnect wallet" : "Wallet not connected"}</button>
        </nav>
    )
}