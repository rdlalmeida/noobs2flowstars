import React, { useState } from 'react';

export default function App() {
	const questions = [
		{
			questionText: "Which phase of the internet was read only?",
			answerOptions: [
				{ answerText: "web1.0", "isCorrect": true },
				{ answerText: "web2.0", "isCorrect": false },
				{ answerText: "web3.0", "isCorrect": false },
				{ answerText: "web4.0", "isCorrect": false }
			]
		},
		{
			questionText: "In which phase is the internet decentralized?",
			answerOptions: [
				{ answerText: "web1.0", "isCorrect": false },
				{ answerText: "web2.0", "isCorrect": false },
				{ answerText: "web3.0", "isCorrect": true },
				{ answerText: "web4.0", "isCorrect": false }
			]
		},
		{
			questionText: "A user can own data on web1.0?",
			answerOptions: [
				{ answerText: "True", "isCorrect": false },
				{ answerText: "False", "isCorrect": true }
			]
		},
		{
			questionText: "How many locations does web2.0 use to store accessible data?",
			answerOptions: [
				{ answerText: "Three locations", "isCorrect": false },
				{ answerText: "One location", "isCorrect": true },
				{ answerText: "No locations", "isCorrect": false },
				{ answerText: "Seven locations", "isCorrect": false }
			]
		},
		{
			questionText: "How does one access data on web3.0?",
			answerOptions: [
				{ answerText: "A magic whiteboard", "isCorrect": false },
				{ answerText: "Snail main in a PO Box", "isCorrect": false },
				{ answerText: "In a blockchain", "isCorrect": true },
				{ answerText: "Through a well tuned microwave", "isCorrect": false }
			]
		}
	];

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
	return (
		<div className='app'>
			{showScore ? (
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
			)}
		</div>
	);
}
