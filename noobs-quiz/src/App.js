import React, { useState, useEffect } from 'react';
import { questions } from "./components/Questions"
import * as fcl from "@onflow/fcl";
import "./flow/config.js"
import styles from "./styles/nav.css"
import raw from "./flow/cadence/transactions/TestTransaction.cdc"

function App() {
	// Get the questions from the dedicated file
	const [question_level, setQuestionLevel] = useState(0)
	const [current_questions, setQuestionSet] = useState(questions[question_level])
	const [currentQuestion, setCurrentQuestion] = useState(0);
	const [showScore, setShowScore] = useState(false);
	const [score, setScore] = useState(0);
	
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

	const resetQuiz = () => {
		setCurrentQuestion(0);
		setScore(0);
		setShowScore(false);
	}

	const advanceQuestionLevel = () => {
		setCurrentQuestion(0);
		setQuestionLevel(question_level + 1);
		setQuestionSet(questions[question_level]);
		setScore(0);
		setShowScore(false);
	}
	// -------------------------------- ELEMENT RENDERING FUNCTIONS ---------------------------------
	const Quiz = () => {
		return(
			<>
			<div className='question-section'>
				<div className='question-count'>
					<h3>Level {question_level + 1}</h3>
					<span>Question {currentQuestion + 1}</span>/{current_questions.length}
				</div>
				<div className='question-text'>{current_questions[currentQuestion].questionText}</div>
			</div>
			<div className='answer-section'>
				{current_questions[currentQuestion].answerOptions.map((answerOption) => (
					<button onClick={() => handleAnswerOptionClick(answerOption.isCorrect)}>{answerOption.answerText}</button>
				))}
			</div>
		</>
		)
	}

	const Score = () => {
		if (score < questions.length) {
			return(
				<div className='score-section'>
					You scored {score} out of {questions.length}.
					{score < current_questions.length/2 ? "\nHumm, you need to study some more" : "\nAlmost there..."}
					<button onClick={resetQuiz}>Restart level</button>
				</div>
			)
		}
		else {
			return (
				<div className='score-section'>
					Congratulations, you scored {score} out of {questions.length}!
					<button>Claim FLOAT</button>
					<button onClick={advanceQuestionLevel}>Next Level</button>
				</div>
			)
		}
	}
	// ----------------------------------------------------------------------------------------------

	// ------------------ CADENCE TRANSACTIONS AND SCRIPTS ------------------------------------------

	async function runAltTestTransaction() {
		const transactionText = await fetch(raw).then(r => r.text())

		const transactionId = await fcl.mutate({
			cadence: transactionText,
			args: (arg, t) => [
				arg(user.addr, t.Address)
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
						<Score />
					) : (
						<Quiz />
					)
				) : (
					<div className='score-section'>Log in to play the quiz</div>
				)}
			</div>
		</div>
	);
}

export default App