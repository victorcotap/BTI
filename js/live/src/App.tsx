import React from 'react';
// import { BrowserRouter, Route, Link } from "react-router-dom";
import Map from './ui/map';

import './App.css';

const App: React.FC = () => {
  return (
    <div className="App">
      <header>
        <h3>Briefing </h3>
        <h3>Map </h3>
        <h3>About</h3>
      </header>
      <div className="App-content">
        <Map />
      </div>
    </div>
  );
}

export default App;
