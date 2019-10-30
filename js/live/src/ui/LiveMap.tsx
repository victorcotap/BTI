import React, { CSSProperties } from 'react';

import Map from './Map';
import CSARSlots from './CSARSlots';

import RedGround from '../assets/Red-Ground.png';
import RedSAM from '../assets/Red-SAM.png';
import RedArmor from '../assets/Red-Armor.png';
import BlueGround from '../assets/Blue-Ground.png';
import { LngLat } from 'mapbox-gl';
import Waypoint from '../model/waypoint';

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
    height: '70vh',
}

const styleSidebar: CSSProperties = {
    boxSizing: "border-box",
    minWidth: "25%",
    flexGrow: 0,
    padding: "10px",
    backgroundColor: "#222222",
    overflowY: "auto",
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

const styleImage: CSSProperties = {
    width: 20,
    height: 20,
}

interface State {
    showSlots: boolean,
    showFlightPlanner: boolean,
    showHeatmap: boolean,
    showBlue: boolean,
    showAirDefenses: boolean,
    showArmor: boolean,
    showGround: boolean,
    route: Waypoint[],
}

export default class LiveMap extends React.Component {
    state: State = {
        showSlots: false,
        showFlightPlanner: false,
        showHeatmap: true,
        showBlue: true,
        showAirDefenses: true,
        showArmor: true,
        showGround: true,
        route: Array<Waypoint>(),
    }

    onClearRoute = () => {
        this.setState({route: Array<Waypoint>()});
    }

    onSelectMapPoint = (point: LngLat, name?: string) => {
        const route = this.state.route
        route.push({latitude: point.lat, longitude: point.lng, elevation: 0, name});
        this.setState({route});
    }

    render() {
        const { showFlightPlanner, showSlots, showAirDefenses, showArmor, showBlue, showGround, showHeatmap } = this.state;
        console.log({route: this.state.route});
        return (
            <div>
                <div style={styleToolbar}>
                    <button style={styleButton} onClick={(event) => this.setState({showSlots: !this.state.showSlots})}>Slots List On/Off</button>
a
                    <div>
                        <input type="checkbox" name="heatmap" defaultChecked={true} onChange={(event) => this.setState({showHeatmap: event.target.checked}) }/>
                        <label> Heatmap</label>
                    </div>
                    <div>
                        <input type="checkbox" name="blue" defaultChecked={true} onChange={(event) => this.setState({showBlue: event.target.checked}) }/>
                        <img style={styleImage} src={BlueGround} alt={''} />
                        <label> BLUFOR</label>
                    </div>
                    <div>
                        <input type="checkbox" name="air-defenses" defaultChecked={true} onChange={(event) => this.setState({showAirDefenses: event.target.checked}) }/>
                        <img style={styleImage} src={RedSAM} alt={''}/>
                        <label> Air Defenses</label>
                    </div>
                    <div>
                        <input type="checkbox" name="armor" defaultChecked={true} onChange={(event) => this.setState({showArmor: event.target.checked}) }/>
                        <img style={styleImage} src={RedArmor} alt={''} />
                        <label> Armor</label>
                    </div>
                    <div>
                        <input type="checkbox" name="ground" defaultChecked={true} onChange={(event) => this.setState({showGround: event.target.checked}) }/>
                        <img style={styleImage} src={RedGround} alt={''}/>
                        <label> Ground forces</label>
                    </div>


                    <button style={styleButton} onClick={(event) => this.setState({showFlightPlanner: !this.state.showFlightPlanner})}>Flight Planning</button>

                </div>
                <div style={styleContentArea}>
                    {showSlots ? (
                        <div style={styleSidebar}>
                            <CSARSlots />
                        </div>
                    ) : null}
                    <div style={styleMap}>
                        <Map
                            showAirDefenses={showAirDefenses}
                            showArmor={showArmor}
                            showBlue={showBlue}
                            showGround={showGround}
                            showHeatmap={showHeatmap}
                            onSelectMapPoint={this.onSelectMapPoint}
                            route={this.state.route}
                        />
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
