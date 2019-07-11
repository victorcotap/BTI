import React from 'react';
import { BrowserRouter, Route, Link } from "react-router-dom";
import Map from './ui/map';

import './App.css';


console.log("toto");

const App: React.FC = () => {
  return (
    <div className="App">
      <header>
        <a>Briefing </a>
        <a>Map </a>
        <a>About</a>
      </header>
      <div className="App-content">
        <Map />
      </div>
    </div>
  );
}

export default App;
