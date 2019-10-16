import React, { CSSProperties } from 'react';
import LiveMap from './ui/LiveMap';

import './App.css';

const styleHeader: CSSProperties = {
  boxSizing: "border-box",
  padding: "10px",
  minHeight: '10vh',
}

const styleLiveMap: CSSProperties = {
  minHeight: '90vh',
}

const App: React.FC = () => {
  return (
    <div className="App">
      <header style={styleHeader}>
        <h1 style={{fontSize: "1.2rem", margin: "0"}}>Advance Warfare</h1>
      </header>
      <div style={styleLiveMap}>
        <LiveMap />
      </div>
    </div>
  );
}

export default App;
