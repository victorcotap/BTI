import React, { CSSProperties } from 'react';
import {
  Switch,
  Route,
  Link,
  BrowserRouter
} from "react-router-dom";


import LiveMap from './ui/LiveMap';
import Rules from './ui/Rules';
import Abstract from './ui/Abstract';
import Airboss from './ui/Airboss';

import './App.css';
import config from './config.json';


const styleHeader: CSSProperties = {
  boxSizing: "border-box",
  padding: "10px",
  minHeight: '5vh',
}

const styleTopSection: CSSProperties = {
  maxHeight: '15vh',
  display: 'flex',
  flexFlow: 'row nowrap',
  justifyContent: 'space-around',
}

const styleLiveMap: CSSProperties = {
  minHeight: '70vh',
}

const styleLink: CSSProperties = {
  color: "#00CC00",
  fontWeight: "bold",
}

const App: React.FC = () => {
  return (
    <BrowserRouter>
      <div className="App">
        <header style={styleHeader}>
          <h1 style={{ fontSize: "1.2rem", margin: "0" }}>{config.serverName}</h1>
        </header>
        <section style={styleTopSection}>
          <Link style={styleLink} to="/">MAP</Link>
          <Link style={styleLink} to="/airboss">GREENIE BOARD</Link>
          {config.showRules ? <Link style={styleLink} to="/rules">RULES</Link> : undefined}
          {config.showAbout ? <Link style={styleLink} to="/about">ABOUT</Link> : undefined}
        </section>
        <section style={styleLiveMap}>
          <Switch>
            <Route path="/airboss">
              <Airboss />
            </Route>
            <Route path="/about">
              <Abstract />
            </Route>
            <Route path="/rules">
              <Rules />
            </Route>
            <Route path="/">
              <LiveMap />
            </Route>
          </Switch>
        </section>
      </div>
    </BrowserRouter>
  );
}

export default App;
