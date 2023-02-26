import React, { useState, useEffect } from 'react';
import { l1_questions } from "./components/Questions"
import * as fcl from "@onflow/fcl";
import "./flow/config.js"
import styles from "./styles/nav.css"
import raw from "./flow/cadence/transactions/TestTransaction.cdc"

function App() {
	// Get the questions from the dedicated file
	const questions = l1_questions
	
	fetch(raw)
		.then(r => r.text())
		.then(text => {
			console.log("Transaction text: ", text)
		});

	const [user, setUser] = useState({ loggedIn: false });

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

	const [currentQuestion, setCurrentQuestion] = useState(0);
	const [showScore, setShowScore] = useState(false);
	const [score, setScore] = useState(0);

	const handleAnswerOptionClick = (isCorrect) => {
		if (isCorrect) {
			setScore(score + 1);
		}

		const nextQuestion = currentQuestion + 1;
		if (nextQuestion < questions.length) {
			setCurrentQuestion(nextQuestion);
		} else {
			setShowScore(true);
		}
	};

	// ------------------ CADENCE TRANSACTIONS AND SCRIPTS ------------------------------------------

	async function runAltTestTransaction() {
		const transactionText = await fetch(raw).then(r => r.text())

		const transactionId = await fcl.mutate({
			cadence: transactionText,
			args: (arg, t) => [
				arg('0x41e49c24e24bd19a', t.Address)
			],
			proposer: fcl.authz,
			payer: fcl.authz,
			authorizations: [fcl.authz],
			limit: 999
		})

		console.log("Alt transaction successfully executed with id " + transactionId)
	}

	// ----------------------------------------------------------------------------------------------

	return (
		<div>
			<nav className={styles.Nav}>
                <h1>Noobs to Flowstars</h1>
                <button onClick={logInUser}>{user.loggedIn ? "Wallet ".concat(user.addr).concat(" connected!") : "Connect wallet"}</button>
                <button onClick={logOffUser}>{user.loggedIn ? "Disconnect wallet" : "Wallet not connected"}</button>
            </nav>
            <footer className={styles.footer}>
                <h1>Transaction testing</h1>
                <div>
                    <button>{user.loggedIn ? "User is logged in" : "User is logged off!"}</button>
                    <button onClick={runAltTestTransaction}>Run Test Transaction</button>
                </div>
        	</footer>
			<h1>Questionnaire: </h1>
			<div className='app'>
				{user.loggedIn ? (
					showScore ? (
						<div className='score-section'>
							You scored {score} out of {questions.length}
						</div>
					) : (
						<>
							<div className='question-section'>
								<div className='question-count'>
									<span>Question {currentQuestion + 1}</span>/{questions.length}
								</div>
								<div className='question-text'>{questions[currentQuestion].questionText}</div>
							</div>
							<div className='answer-section'>
								{questions[currentQuestion].answerOptions.map((answerOption) => (
									<button onClick={() => handleAnswerOptionClick(answerOption.isCorrect)}>{answerOption.answerText}</button>
								))}
							</div>
						</>
					)
				) : (
					<div className='score-section'>Log in to play the quiz</div>
				)}
			</div>
		</div>
	);
}

export default App