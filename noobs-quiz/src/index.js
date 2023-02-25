import React from 'react';
import ReactDOM from 'react-dom';
import './styles/index.css';
import App from './App';
import Nav from "./components/Nav"

ReactDOM.render(
  <React.StrictMode>
    <div>
      <Nav />
      <App />
    </div>
  </React.StrictMode>,
  document.getElementById('root')
);
