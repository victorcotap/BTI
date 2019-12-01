import React, { CSSProperties } from 'react';

import MapboxElevation from 'mapbox-elevation';
import { LngLat } from 'mapbox-gl';

import Map from './Map';
import CSARSlots from './CSARSlots';
import FlightPlanner from './FlightPlanner';


import Waypoint, { WaypointType } from '../model/waypoint';
import {genColor} from '../utils/colorUtils';

const getElevation = MapboxElevation("pk.eyJ1IjoidmljdG9yY290YXAiLCJhIjoiY2p4eTdvZjRhMDdpejNtb2FmenRvenk0cCJ9.lf2sq-jELqUvTyPil0tWRA")

const styleToolbar: CSSProperties = {
    boxSizing: "border-box",
    minHeight: '5vh',
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'flex-end',
    paddingLeft: "10px",
    paddingRight: "10px",
    marginBottom: "15px"
}

const styleContentArea: CSSProperties = {
    boxSizing: "border-box",
    display: 'flex',
    flexDirection: "row",
    flexWrap: "nowrap",
    justifyContent: 'space-between',
    height: '85vh',
}

const styleSidebar: CSSProperties = {
    boxSizing: "border-box",
    minWidth: "25%",
    maxWidth: "33%",
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
    backgroundColor: "#aaaaaa",
    color: "#333333",
    height: "2rem",
    border: "none",
    borderRadius: "5px",
    boxShadow: "4px 4px 2px 2px #555555",
}
const selectedStyleButton: CSSProperties = {
    boxShadow: "4px 4px 2px 2px orange",
}

interface State {
    showSlots: boolean,
    showFlightPlanner: boolean,
    route: Waypoint[],
}

export default class LiveMap extends React.Component {
    state: State = {
        showSlots: false,
        showFlightPlanner: false,
        route: Array<Waypoint>(),
    }

    onClearRoute = () => {
        this.setState({route: Array<Waypoint>()});
    }
    onSwapWaypoint = (waypointIndex: number, newWaypointIndex: number) => {
        const route = this.state.route;
        const swappedWaypoint = this.state.route[waypointIndex];
        route[waypointIndex] = route[newWaypointIndex];
        route[newWaypointIndex] = swappedWaypoint;
        this.setState({route});
    }
    onDeleteWaypoint = (waypointIndex: number) => {
        const route = this.state.route;
        route.splice(waypointIndex, 1);
        this.setState({route});
    }

    onSelectMapPoint = (point: LngLat, type: WaypointType, name?: string, ) => {
        if (!this.state.showFlightPlanner && !name) { return }
        const route = this.state.route
        getElevation([point.lng, point.lat], (error: Error, elevation: number) => {
            if (error) { console.warn(error); }
            const color = type === WaypointType.waypoint ? '#' + genColor(point.lat + point.lng) : undefined;
            route.push({latitude: point.lat, longitude: point.lng, elevation, name, color, type});
            this.setState({route});
        })
    }

    render() {
        const { showFlightPlanner, showSlots} = this.state;
        const slotsButtonStyle = showSlots ? {...styleButton, ...selectedStyleButton} : styleButton;
        const fpButtonStyle = showFlightPlanner ? {...styleButton, ...selectedStyleButton} : styleButton;

        return (
            <div>
                <div style={styleToolbar}>
                    <button style={slotsButtonStyle} onClick={(event) => this.setState({showSlots: !this.state.showSlots})}> Toggle Slots List</button>
                    <button style={fpButtonStyle} onClick={(event) => this.setState({showFlightPlanner: !this.state.showFlightPlanner})}>Flight Planning Mode</button>
                </div>
                <div style={styleContentArea}>
                    {showSlots ? (
                        <div style={styleSidebar}>
                            <CSARSlots />
                        </div>
                    ) : null}
                    <div style={styleMap}>
                        <Map
                            onSelectMapPoint={this.onSelectMapPoint}
                            route={this.state.route}
                        />
                    </div>
                    {showFlightPlanner ? (
                        <div style={styleSidebar}>
                            <FlightPlanner route={this.state.route} onClearRoute={this.onClearRoute} onSwapWaypoint={this.onSwapWaypoint} onDeleteWaypoint={this.onDeleteWaypoint}/>
                        </div>
                    ) : null}
                </div>
            </div>
        );
    }
}
