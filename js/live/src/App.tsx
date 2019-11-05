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

import './App.css';

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
  color: "green",
  fontWeight: "bold",
}

const App: React.FC = () => {
  return (
    <BrowserRouter>
      <div className="App">
        <header style={styleHeader}>
          <h1 style={{ fontSize: "1.2rem", margin: "0" }}>APEX Advance Warfare</h1>
        </header>
        <section style={styleTopSection}>
          <Link style={styleLink} to="/">Map</Link>
          <Link style={styleLink} to="/airboss">Airboss</Link>
          <Link style={styleLink} to="/rules">Rules</Link>
          <Link style={styleLink} to="/about">About</Link>
        </section>
        <section style={styleLiveMap}>
          <Switch>
            <Route path="/airboss">
              {undefined}
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
