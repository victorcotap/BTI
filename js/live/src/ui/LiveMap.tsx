import React, { CSSProperties } from 'react';

import Map from './map';
import CSARSlots from './CSARSlots';

const styleToolbar: CSSProperties = {
    boxSizing: "border-box",
    minHeight: '5vh',
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'flex-end',
    paddingLeft: "10px",
    paddingRight: "10px",
    paddingBottom: '5px',
}

const styleContentArea: CSSProperties = {
    boxSizing: "border-box",
    display: 'flex',
    flexDirection: "row",
    flexWrap: "nowrap",
    justifyContent: 'space-between',
    height: '75vh',
}

const styleSidebar: CSSProperties = {
    boxSizing: "border-box",
    maxWidth: "25%",
    flexGrow: 0,
    padding: "10px",
    backgroundColor: "#222222",
    overflow: "hidden",
}

const styleMap: CSSProperties = {
    boxSizing: "border-box",
    flexGrow: 1,
    margin: "0 10px"
}

const styleButton: CSSProperties = {
    boxSizing: "border-box",   
    margin: "0 10px 0 0",
    backgroundColor: "#ffffff",
    color: "#333333",
    height: "2rem",
    border: "none"
}

interface State {
    showSlots: boolean,
    showFlightPlanner: boolean,
}

export default class LiveMap extends React.Component {
    state: State = {
        showSlots: false,
        showFlightPlanner: false,
    }

    render() {
        const { showFlightPlanner, showSlots } = this.state;

        return (
            <div>
                <div style={styleToolbar}>
                    <button style={styleButton} onClick={(event) => this.setState({showSlots: !this.state.showSlots})}>Slots List</button>
                    <button style={styleButton} onClick={(event) => this.setState({showFlightPlanner: !this.state.showFlightPlanner})}>Flight Planning</button>
                </div>
                <div style={styleContentArea}>
                    {showSlots ? (
                        <div style={styleSidebar}>
                            <CSARSlots />
                        </div>
                    ) : null}
                    <div style={styleMap}>
                        <Map />
                    </div>
                    {showFlightPlanner ? (
                        <div style={styleSidebar}>
                            <p>Ask ED to release their data cartridge</p>
                        </div>
                    ) : null}
                </div>
            </div>
        );
    }
}
