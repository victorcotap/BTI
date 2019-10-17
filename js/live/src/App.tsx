import React, { CSSProperties } from 'react';
import LiveMap from './ui/LiveMap';
import Rules from './ui/Rules';
import Abstract from './ui/Abstract';

import './App.css';

const styleHeader: CSSProperties = {
  boxSizing: "border-box",
  padding: "10px",
  minHeight: '5vh',
}

const styleTopSection: CSSProperties = {
  minHeight: '15vh',
  display: 'flex',
  flexFlow: 'row nowrap',
  justifyContent: 'space-around',
}

const styleLiveMap: CSSProperties = {
  minHeight: '70vh',
}

const App: React.FC = () => {
  return (
    <div className="App">
      <header style={styleHeader}>
        <h1 style={{fontSize: "1.2rem", margin: "0"}}>APEX Advance Warfare</h1>
      </header>
      <section style={styleTopSection}>
        <div style={{width: "50%"}}><Abstract /></div>
        <div style={{width: "50%"}}><Rules /></div>
      </section>
      <section style={styleLiveMap}>
        <LiveMap />
      </section>
    </div>
  );
}

export default App;
